-- Bot pencuri: beli di belt, bawa pulang, dan curi dari base pemain yang tak terkunci.
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Server = ServerScriptService:WaitForChild("Server")
local Economy = require(Shared:WaitForChild("Economy"))
local GameState = require(Shared:WaitForChild("GameState"))
local WorldBuilder = require(Server:WaitForChild("WorldBuilder"))
local CharacterFactory = require(Server:WaitForChild("CharacterFactory"))
local BeltSpawner = require(Server:WaitForChild("BeltSpawner"))
local BaseManager = require(Server:WaitForChild("BaseManager"))
local WaveSystem = require(Server:WaitForChild("WaveSystem"))
local Remotes = require(Server:WaitForChild("Remotes"))

local BotPemain = {}

local bots = {}

local function posisiBot(bot)
	return bot.Model:GetPivot().Position
end

local function bawaIkut(bot)
	if bot.Membawa and bot.Membawa.Model.Parent then
		local posisi = posisiBot(bot)
		bot.Membawa.Model:PivotTo(CFrame.new(posisi + Vector3.new(0, 2, 2.5)))
	end
end

local function pulang(bot)
	local base = bot.Base
	bot.Model:PivotTo(CFrame.new(base.Posisi + Vector3.new(0, 2, 0)))
	if bot.Membawa then
		BotPemain.simpanBawaan(bot)
	end
end

function BotPemain.kumpulkanIncome(bot)
	local data = GameState.Bot[bot.Nama]
	if not data then
		return
	end
	local total = 0
	for _, slot in pairs(data.Slot) do
		if slot then
			local traits = {}
			if slot.Trait then
				table.insert(traits, slot.Trait)
			end
			total = total + Economy.hitungIncome(slot.Data, slot.Mutasi.Pengali, traits, GameState.pengaliRebirth(data.Rebirth))
		end
	end
	data.Uang = data.Uang + total
end

function BotPemain.simpanBawaan(bot)
	local bawa = bot.Membawa
	if not bawa then
		return
	end
	bot.Membawa = nil
	if not bawa.Model.Parent then
		return
	end
	local entri = { Model = bawa.Model, Data = bawa.Data, Mutasi = bawa.Mutasi, Trait = bawa.Trait }
	if not BaseManager.taruhDiBaseBot(bot.Nama, bot.BaseNama, entri) then
		bawa.Model:Destroy()
	end
end

function BotPemain.bergerakKe(bot, tujuan)
	local langkah = 0
	while langkah < 600 do
		local posisi = posisiBot(bot)
		local arah = Vector3.new(tujuan.X - posisi.X, 0, tujuan.Z - posisi.Z)
		local jarak = arah.Magnitude
		if jarak < 3 then
			return true
		end
		local gerak = arah.Unit * math.min(0.5, jarak)
		bot.Model:PivotTo(CFrame.new(posisi + gerak))
		bawaIkut(bot)
		if GameState.Ombak.Status == "Banjir" and posisi.Z < GameState.Ombak.Z + 6 then
			if not WaveSystem.cekParitAman(posisi) and not WaveSystem.cekDiBase(posisi) then
				if bot.Membawa then
					local bawa = bot.Membawa
					bot.Membawa = nil
					if bawa.AsalPemain and GameState.Pemain[bawa.AsalPemain] then
						BaseManager.taruhDiBase(bawa.AsalPemain, { Model = bawa.Model, Data = bawa.Data, Mutasi = bawa.Mutasi, Trait = bawa.Trait })
					else
						BeltSpawner.spawnSatu(bawa.Data)
						bawa.Model:Destroy()
					end
				end
				pulang(bot)
				return false
			end
		end
		langkah = langkah + 1
		task.wait(0.08)
	end
	return false
end

function BotPemain.beliDiBelt(bot)
	local data = GameState.Bot[bot.Nama]
	if not data then
		return
	end
	local daftar = BeltSpawner.daftarBelt()
	if #daftar == 0 then
		return
	end
	local entri = daftar[math.random(1, #daftar)]
	if not entri.Model.Parent then
		return
	end
	if data.Uang < entri.Data.Harga then
		return
	end
	local posisi = entri.Model:GetPivot().Position
	if not BotPemain.bergerakKe(bot, posisi) then
		return
	end
	if not entri.Hidup or not entri.Model.Parent then
		return
	end
	data.Uang = data.Uang - entri.Data.Harga
	BeltSpawner.ambilDariBelt(entri)
	bot.Membawa = { Model = entri.Model, Data = entri.Data, Mutasi = entri.Mutasi, Trait = entri.Trait, AsalPemain = nil }
	BotPemain.bergerakKe(bot, bot.Base.Posisi)
	BotPemain.simpanBawaan(bot)
end

function BotPemain.pilihSlotTermahal(data)
	local terbaik = nil
	local incomeTerbaik = -1
	for _, satu in pairs(data.Slot) do
		if satu then
			local traits = {}
			if satu.Trait then
				table.insert(traits, satu.Trait)
			end
			local income = Economy.hitungIncome(satu.Data, satu.Mutasi.Pengali, traits, 1)
			if income > incomeTerbaik then
				incomeTerbaik = income
				terbaik = satu
			end
		end
	end
	return terbaik
end

function BotPemain.curiDariPemain(bot)
	for player, data in pairs(GameState.Pemain) do
		if not GameState.baseTerkunci(data) then
			local slot = BotPemain.pilihSlotTermahal(data)
			if slot then
				local basePemain = WorldBuilder.Info.Bases.Pemain
				if not BotPemain.bergerakKe(bot, basePemain.Posisi) then
					return
				end
				if not slot.Model.Parent then
					return
				end
				BaseManager.lepasDariSlot(player, slot.Model)
				slot.Model:SetAttribute("DiBase", false)
				bot.Membawa = { Model = slot.Model, Data = slot.Data, Mutasi = slot.Mutasi, Trait = slot.Trait, AsalPemain = player }
				Remotes.ambil("BeriPesan"):FireClient(player, "AWAS! " .. bot.Nama .. " mencuri " .. slot.Model.Name .. " dari basemu!")
				BotPemain.bergerakKe(bot, bot.Base.Posisi)
				BotPemain.simpanBawaan(bot)
				return
			end
		end
	end
end

function BotPemain.jalankanBot(bot)
	while true do
		task.wait(math.random(4, 8))
		BotPemain.kumpulkanIncome(bot)
		if math.random(100) <= 60 then
			BotPemain.beliDiBelt(bot)
		else
			BotPemain.curiDariPemain(bot)
		end
	end
end

function BotPemain.mulai()
	local daftar = {
		{ Nama = "Bot Sari", Warna = Color3.fromRGB(255, 120, 180), BaseNama = "Bot1" },
		{ Nama = "Bot Budi", Warna = Color3.fromRGB(80, 200, 255), BaseNama = "Bot2" },
		{ Nama = "Bot Cici", Warna = Color3.fromRGB(140, 255, 140), BaseNama = "Bot3" },
	}
	for _, info in ipairs(daftar) do
		local base = WorldBuilder.Info.Bases[info.BaseNama]
		local model = CharacterFactory.buatBot(info.Nama, info.Warna)
		model:PivotTo(CFrame.new(base.Posisi + Vector3.new(0, 2, 0)))
		model.Parent = Workspace
		local data = GameState.dataBaru()
		data.KunciSampai = tick() + GameState.durasiKunci(0)
		GameState.Bot[info.Nama] = data
		local bot = { Nama = info.Nama, Model = model, Base = base, BaseNama = info.BaseNama, Membawa = nil }
		table.insert(bots, bot)
		task.spawn(function()
			BotPemain.jalankanBot(bot)
		end)
	end
end

return BotPemain
