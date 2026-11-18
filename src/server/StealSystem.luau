-- R3 rewrite terekam 2026-11-18.
-- Ancaman 1, maling: curi dari base tak terkunci, pikul lambat, tampar menjatuhkan.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Server = ServerScriptService:WaitForChild("Server")
local GameState = require(Shared:WaitForChild("GameState"))
local WorldBuilder = require(Server:WaitForChild("WorldBuilder"))
local BaseManager = require(Server:WaitForChild("BaseManager"))
local Remotes = require(Server:WaitForChild("Remotes"))

local StealSystem = {}

local bawaan = {}
local terakhirTampar = {}

local function aturJalan(player, cepat)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local data = GameState.Pemain[player]
		if cepat then
			if data and data.Rebirth >= 3 then
				humanoid.WalkSpeed = GameState.Konfigurasi.JalanCoil
			else
				humanoid.WalkSpeed = GameState.Konfigurasi.JalanNormal
			end
		else
			humanoid.WalkSpeed = GameState.Konfigurasi.JalanMemikul
		end
	end
end

function StealSystem.sedangMembawa(player)
	return bawaan[player] ~= nil
end

function StealSystem.mulaiBawa(player, model, jenis, asal, saatSampai, saatJatuh, entriData)
	if GameState.Pemain[player] and GameState.Pemain[player].Membawa then
		return false
	end
	bawaan[player] = { Model = model, Jenis = jenis, Asal = asal, SaatSampai = saatSampai, SaatJatuh = saatJatuh, EntriData = entriData }
	if GameState.Pemain[player] then
		GameState.Pemain[player].Membawa = model
	end
	aturJalan(player, false)
	task.spawn(function()
		while bawaan[player] and bawaan[player].Model == model do
			local character = player.Character
			local akar = character and character:FindFirstChild("HumanoidRootPart")
			if akar then
				model:PivotTo(akar.CFrame * CFrame.new(0, 2, 2.5))
				local base = WorldBuilder.Info.Bases.Pemain
				local jarak = (Vector3.new(akar.Position.X, 0, akar.Position.Z) - Vector3.new(base.Posisi.X, 0, base.Posisi.Z)).Magnitude
				if jarak < 22 then
					local entri = bawaan[player]
					bawaan[player] = nil
					if GameState.Pemain[player] then
						GameState.Pemain[player].Membawa = nil
					end
					aturJalan(player, true)
					if entri.SaatSampai then
						entri.SaatSampai()
					end
					break
				end
			end
			task.wait(0.1)
		end
	end)
	return true
end

function StealSystem.jatuhkanBawaan(player)
	local entri = bawaan[player]
	if not entri then
		return
	end
	bawaan[player] = nil
	if GameState.Pemain[player] then
		GameState.Pemain[player].Membawa = nil
	end
	aturJalan(player, true)
	local character = player.Character
	local akar = character and character:FindFirstChild("HumanoidRootPart")
	local posisi = akar and akar.Position or Vector3.new(0, 2, 120)
	entri.Model:SetAttribute("Jatuh", true)
	entri.Model:PivotTo(CFrame.new(Vector3.new(posisi.X, 2, posisi.Z)))
	entri.Model:SetAttribute("JatuhSampai", tick() + 15)
	if entri.SaatJatuh then
		entri.SaatJatuh()
	end
	task.delay(15, function()
		if entri.Model:GetAttribute("Jatuh") then
			entri.Model:SetAttribute("Jatuh", false)
			if entri.Jenis == "Brainrot" and entri.Asal and entri.EntriData and GameState.Pemain[entri.Asal] then
				BaseManager.taruhDiBase(entri.Asal, entri.EntriData)
			end
		end
	end)
end

function StealSystem.curiBrainrot(player, model, pemilik, entri)
	if GameState.Pemain[player] and GameState.Pemain[player].Membawa then
		Remotes.ambil("BeriPesan"):FireClient(player, "Tanganmu penuh! Taruh dulu bawaanmu di base.")
		return
	end
	BaseManager.lepasDariSlot(pemilik, model)
	model:SetAttribute("DiBase", false)
	local entriBawa = { Model = model, Data = entri.Data, Mutasi = entri.Mutasi, Trait = entri.Trait }
	StealSystem.mulaiBawa(player, model, "Brainrot", pemilik, function()
		BaseManager.taruhDiBase(player, entriBawa)
		Remotes.ambil("BeriPesan"):FireClient(player, "Berhasil! " .. model.Name .. " sekarang milikmu.")
	end, nil, entriBawa)
	Remotes.ambil("BeriPesan"):FireClient(pemilik, "AWAS! " .. player.Name .. " mencuri " .. model.Name .. " dari basemu! Tampar dia!")
end

function StealSystem.daftarkanBrainrotBase(model, pemilik, entri)
	local badan = model:FindFirstChild("Badan")
	local klik = badan and badan:FindFirstChildOfClass("ClickDetector")
	if not klik then
		return
	end
	klik.MouseClick:Connect(function(player)
		if model:GetAttribute("Jatuh") then
			if GameState.Pemain[player] and GameState.Pemain[player].Membawa then
				return
			end
			model:SetAttribute("Jatuh", false)
			StealSystem.mulaiBawa(player, model, "Brainrot", nil, function()
				BaseManager.taruhDiBase(player, entri)
			end, nil, entri)
			return
		end
		if not model:GetAttribute("DiBase") then
			return
		end
		if player == pemilik then
			return
		end
		local dataPemilik = GameState.Pemain[pemilik]
		if dataPemilik and GameState.baseTerkunci(dataPemilik) then
			Remotes.ambil("BeriPesan"):FireClient(player, "Base " .. pemilik.Name .. " masih terkunci!")
			return
		end
		StealSystem.curiBrainrot(player, model, pemilik, entri)
	end)
end

function StealSystem.tampar(player)
	local sekarang = tick()
	if terakhirTampar[player] and sekarang - terakhirTampar[player] < 2 then
		return
	end
	terakhirTampar[player] = sekarang
	local character = player.Character
	local akar = character and character:FindFirstChild("HumanoidRootPart")
	if not akar then
		return
	end
	for target, entri in pairs(bawaan) do
		local karakterTarget = target.Character
		local akarTarget = karakterTarget and karakterTarget:FindFirstChild("HumanoidRootPart")
		if akarTarget and (akarTarget.Position - akar.Position).Magnitude < 10 then
			StealSystem.jatuhkanBawaan(target)
			Remotes.ambil("BeriPesan"):FireClient(player, "Tampar! " .. target.Name .. " menjatuhkan " .. entri.Model.Name .. "!")
			Remotes.ambil("BeriPesan"):FireClient(target, "Kamu ditampar " .. player.Name .. "! Bawaanmu jatuh!")
			return
		end
	end
	Remotes.ambil("BeriPesan"):FireClient(player, "Tidak ada pencuri di dekatmu.")
end

function StealSystem.mulai()
	Remotes.ambil("AksiTampar").OnServerEvent:Connect(function(player)
		StealSystem.tampar(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		if bawaan[player] then
			StealSystem.jatuhkanBawaan(player)
		end
		terakhirTampar[player] = nil
	end)
end

return StealSystem
