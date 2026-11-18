-- Base pemain + bot: beli, taruh di slot, kunci, income tiap detik, kirim HUD.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Server = ServerScriptService:WaitForChild("Server")
local GameState = require(Shared:WaitForChild("GameState"))
local Economy = require(Shared:WaitForChild("Economy"))
local WorldBuilder = require(Server:WaitForChild("WorldBuilder"))
local Remotes = require(Server:WaitForChild("Remotes"))

local BaseManager = {}

-- Hook dari StealSystem (diisi init, supaya tidak ada require melingkar):
-- BaseManager.SaatTaruh(model, pemilik, entri)
BaseManager.SaatTaruh = nil

local function slotKosong(data)
	for i = 1, data.SlotMaks do
		if not data.Slot[i] then
			return i
		end
	end
	return nil
end

-- Hitung slot terisi dengan pairs, bukan ipairs: slot yang dicuri meninggalkan
-- lubang nil di tengah tabel, dan ipairs berhenti di lubang pertama sehingga
-- income + hitungan slot jadi kurang. pairs memindai semua indeks.
function BaseManager.slotTerisi(data)
	local terisi = 0
	for _, slot in pairs(data.Slot) do
		if slot then
			terisi = terisi + 1
		end
	end
	return terisi
end

local function hitungPerDetik(data)
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
	return total
end

function BaseManager.taruhDiBase(pemilik, entri)
	local data = GameState.Pemain[pemilik]
	local base = WorldBuilder.Info.Bases.Pemain
	if not data or not base then
		return false
	end
	local indeks = slotKosong(data)
	if not indeks then
		return false
	end
	entri.Model:SetAttribute("DiBase", true)
	entri.Model:SetAttribute("Jatuh", false)
	entri.Model:SetAttribute("Pemilik", pemilik.Name)
	entri.Model:PivotTo(CFrame.new(base.SlotPos[indeks]))
	data.Slot[indeks] = { Model = entri.Model, Data = entri.Data, Mutasi = entri.Mutasi, Trait = entri.Trait }
	if BaseManager.SaatTaruh then
		BaseManager.SaatTaruh(entri.Model, pemilik, entri)
	end
	return true
end

function BaseManager.taruhDiBaseBot(namaBot, kunciBase, entri)
	local data = GameState.Bot[namaBot]
	local base = WorldBuilder.Info.Bases[kunciBase]
	if not data or not base then
		return false
	end
	local indeks = slotKosong(data)
	if not indeks then
		return false
	end
	entri.Model:SetAttribute("DiBase", true)
	entri.Model:SetAttribute("Jatuh", false)
	entri.Model:SetAttribute("Pemilik", namaBot)
	entri.Model:PivotTo(CFrame.new(base.SlotPos[indeks]))
	data.Slot[indeks] = { Model = entri.Model, Data = entri.Data, Mutasi = entri.Mutasi, Trait = entri.Trait }
	return true
end

function BaseManager.lepasDariSlot(pemilik, model)
	local data = GameState.Pemain[pemilik]
	if data then
		for i, slot in pairs(data.Slot) do
			if slot and slot.Model == model then
				data.Slot[i] = nil
				return true
			end
		end
	end
	for _, dataBot in pairs(GameState.Bot) do
		for i, slot in pairs(dataBot.Slot) do
			if slot and slot.Model == model then
				dataBot.Slot[i] = nil
				return true
			end
		end
	end
	return false
end

function BaseManager.buatDataPemain(player)
	local data = GameState.dataBaru()
	-- Base langsung terkunci saat join, supaya tidak langsung dijarah bot.
	data.KunciSampai = tick() + GameState.durasiKunci(0)
	GameState.Pemain[player] = data
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		if data.Rebirth >= 3 then
			humanoid.WalkSpeed = GameState.Konfigurasi.JalanCoil
		else
			humanoid.WalkSpeed = GameState.Konfigurasi.JalanNormal
		end
	end)
end

function BaseManager.hapusDataPemain(player)
	local data = GameState.Pemain[player]
	if data then
		for _, slot in pairs(data.Slot) do
			if slot and slot.Model then
				slot.Model:Destroy()
			end
		end
	end
	GameState.Pemain[player] = nil
end

function BaseManager.kunciBase(player)
	local data = GameState.Pemain[player]
	if not data then
		return
	end
	local pesan = Remotes.ambil("BeriPesan")
	if GameState.baseTerkunci(data) then
		pesan:FireClient(player, "Base masih terkunci " .. GameState.sisaKunci(data) .. " dtk lagi.")
		return
	end
	data.KunciSampai = tick() + GameState.durasiKunci(data.Rebirth)
	pesan:FireClient(player, "Base dikunci " .. GameState.durasiKunci(data.Rebirth) .. " dtk! Maling tidak bisa masuk.")
end

-- Peta nama bot -> kunci base di WorldBuilder.Info.Bases.
local kunciBaseBot = {
	["Bot Sari"] = "Bot1",
	["Bot Budi"] = "Bot2",
	["Bot Cici"] = "Bot3",
}

function BaseManager.mulai()
	Remotes.ambil("AksiKunci").OnServerEvent:Connect(function(player)
		BaseManager.kunciBase(player)
	end)
	task.spawn(function()
		local updateHUD = Remotes.ambil("UpdateHUD")
		while true do
			task.wait(1)
			for player, data in pairs(GameState.Pemain) do
				local perDetik = hitungPerDetik(data)
				data.Uang = data.Uang + perDetik
				local kunciSisa = GameState.sisaKunci(data)
				updateHUD:FireClient(player, data.Uang, perDetik, GameState.Ombak.Status, GameState.Ombak.Sisa, GameState.Ombak.Kecepatan, kunciSisa, data.Rebirth, BaseManager.slotTerisi(data), data.SlotMaks)
			end
			-- Gerbang laser menutup (CanCollide) hanya saat base pemiliknya terkunci.
			local info = WorldBuilder.Info
			if info then
				for _, data in pairs(GameState.Pemain) do
					info.Bases.Pemain.Gerbang.CanCollide = GameState.baseTerkunci(data)
				end
				for namaBot, dataBot in pairs(GameState.Bot) do
					local kunci = kunciBaseBot[namaBot]
					if kunci and info.Bases[kunci] then
						info.Bases[kunci].Gerbang.CanCollide = GameState.baseTerkunci(dataBot)
					end
				end
			end
		end
	end)
end

return BaseManager
