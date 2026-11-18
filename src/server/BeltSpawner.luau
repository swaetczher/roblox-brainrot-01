-- R3 rewrite terekam 2026-11-18.
-- Karpet merah: brainrot berjalan di belt, bisa dibeli; yang sudah dibeli bisa disalip 150%.
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Server = ServerScriptService:WaitForChild("Server")
local CharacterData = require(Shared:WaitForChild("CharacterData"))
local Economy = require(Shared:WaitForChild("Economy"))
local GameState = require(Shared:WaitForChild("GameState"))
local CharacterFactory = require(Server:WaitForChild("CharacterFactory"))
local BaseManager = require(Server:WaitForChild("BaseManager"))
local WorldBuilder = require(Server:WaitForChild("WorldBuilder"))
local Remotes = require(Server:WaitForChild("Remotes"))

local BeltSpawner = {}

local belt = {}
local terakhirLegendary = 0
local terakhirMythic = 0
local BELT_MAKS = 12
local JEDA_SPAWN = 5
local JEDA_LEGENDARY = 300
local JEDA_MYTHIC = 900

function BeltSpawner.daftarBelt()
	return belt
end

function BeltSpawner.jumlahBelt()
	return #belt
end

function BeltSpawner.ambilDariBelt(entri)
	for i, satu in ipairs(belt) do
		if satu == entri then
			table.remove(belt, i)
			break
		end
	end
	entri.Hidup = false
	entri.DiBelt = false
end

function BeltSpawner.hapus(entri)
	BeltSpawner.ambilDariBelt(entri)
	if entri.Model and entri.Model.Parent then
		entri.Model:Destroy()
	end
end

function BeltSpawner.beli(player, entri)
	if not entri.Hidup then
		return
	end
	local data = GameState.Pemain[player]
	if not data then
		return
	end
	local pesan = Remotes.ambil("BeriPesan")
	if not entri.Dibeli then
		if data.Uang < entri.Data.Harga then
			pesan:FireClient(player, "Uang kurang! Butuh " .. Economy.formatUang(entri.Data.Harga) .. " untuk " .. entri.Data.Nama .. ".")
			return
		end
		data.Uang = data.Uang - entri.Data.Harga
		entri.Dibeli = true
		entri.Pembeli = player
		entri.DiBelt = false
		pesan:FireClient(player, "Dibeli: " .. entri.Data.Nama .. "! Bawa pulang ke basemu.")
		BeltSpawner.antarKeBase(entri)
	else
		if entri.Pembeli == player then
			return
		end
		local hargaSalip = Economy.hargaSalip(entri.Data.Harga)
		if data.Uang < hargaSalip then
			pesan:FireClient(player, "Menyalip butuh " .. Economy.formatUang(hargaSalip) .. " (150% harga)!")
			return
		end
		local pembeliLama = entri.Pembeli
		local dataLama = pembeliLama and GameState.Pemain[pembeliLama]
		if dataLama then
			dataLama.Uang = dataLama.Uang + entri.Data.Harga
			pesan:FireClient(pembeliLama, entri.Data.Nama .. " disalip " .. player.Name .. "! Uangmu dikembalikan.")
		end
		data.Uang = data.Uang - hargaSalip
		entri.Pembeli = player
		pesan:FireClient(player, "Disalip! " .. entri.Data.Nama .. " sekarang jalan ke basemu.")
		BeltSpawner.antarKeBase(entri)
	end
end

function BeltSpawner.antarKeBase(entri)
	task.spawn(function()
		local tujuan = WorldBuilder.Info.Bases.Pemain.SlotPos[1]
		local langkah = 0
		while entri.Hidup and entri.Model.Parent and langkah < 400 do
			local posisi = entri.Model:GetPivot().Position
			local arah = tujuan - posisi
			local jarak = arah.Magnitude
			if jarak < 4 then
				break
			end
			local gerak = arah.Unit * math.min(4, jarak)
			entri.Model:PivotTo(CFrame.new(posisi + Vector3.new(gerak.X, 0, gerak.Z)))
			langkah = langkah + 1
			task.wait(0.1)
		end
		if not entri.Hidup then
			return
		end
		BeltSpawner.ambilDariBelt(entri)
		entri.Hidup = false
		if entri.Pembeli and GameState.Pemain[entri.Pembeli] then
			if not BaseManager.taruhDiBase(entri.Pembeli, entri) then
				local pesan = Remotes.ambil("BeriPesan")
				pesan:FireClient(entri.Pembeli, "Base penuh! " .. entri.Data.Nama .. " tidak bisa ditaruh.")
				entri.Model:Destroy()
			end
		end
	end)
end

function BeltSpawner.spawnSatu(dataKhusus)
	if #belt >= BELT_MAKS then
		return nil
	end
	local data = dataKhusus or CharacterData.ambilAcak()
	local mutasi = CharacterData.ambilMutasiAcak()
	local trait = CharacterData.ambilTraitAcak()
	local model = CharacterFactory.buatBrainrot(data, mutasi, trait, 1)
	model:PivotTo(CFrame.new(WorldBuilder.Info.BeltAwal))
	model.Parent = Workspace
	local entri = { Model = model, Data = data, Mutasi = mutasi, Trait = trait, Hidup = true, DiBelt = true, Dibeli = false, Pembeli = nil }
	table.insert(belt, entri)
	local badan = model:FindFirstChild("Badan")
	local klik = badan and badan:FindFirstChildOfClass("ClickDetector")
	if klik then
		klik.MouseClick:Connect(function(player)
			if entri.DiBelt or entri.Dibeli then
				BeltSpawner.beli(player, entri)
			end
		end)
	end
	task.spawn(function()
		while entri.Hidup and entri.DiBelt do
			task.wait(0.1)
			if not entri.Hidup or not entri.DiBelt then
				break
			end
			local posisi = model:GetPivot().Position
			if posisi.Z >= WorldBuilder.Info.BeltAkhir.Z then
				break
			end
			model:PivotTo(CFrame.new(posisi + Vector3.new(0, 0, 0.4)))
		end
		if entri.Hidup and entri.DiBelt then
			BeltSpawner.hapus(entri)
		end
	end)
	return entri
end

function BeltSpawner.mulai()
	task.spawn(function()
		while true do
			task.wait(JEDA_SPAWN)
			local sekarang = tick()
			local spawnKhusus = false
			if sekarang - terakhirLegendary >= JEDA_LEGENDARY then
				terakhirLegendary = sekarang
				BeltSpawner.spawnSatu(CharacterData.ambilDariRarity("Legendary"))
				spawnKhusus = true
			end
			if sekarang - terakhirMythic >= JEDA_MYTHIC then
				terakhirMythic = sekarang
				BeltSpawner.spawnSatu(CharacterData.ambilDariRarity("Mythic"))
				spawnKhusus = true
			end
			if not spawnKhusus then
				BeltSpawner.spawnSatu()
			end
		end
	end)
end

return BeltSpawner
