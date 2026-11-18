-- Rebirth 5 tingkat: reset uang + brainrot demi pengali permanen dan unlock.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Server = ServerScriptService:WaitForChild("Server")
local Economy = require(Shared:WaitForChild("Economy"))
local GameState = require(Shared:WaitForChild("GameState"))
local WorldBuilder = require(Server:WaitForChild("WorldBuilder"))
local Remotes = require(Server:WaitForChild("Remotes"))

local RebirthSystem = {}

RebirthSystem.Syarat = {
	{ Uang = 500000, Butuh = {"Ayam Geprek Joget", "Kucing Oren Barista"}, Buka = "Slap + kunci +10 dtk" },
	{ Uang = 5000000, Butuh = {"Baso Aci Raksasa", "Nasi Padang Terbang"}, Buka = "Lantai 2 base (+4 slot)" },
	{ Uang = 50000000, Butuh = {"Komodo Naik Skuter", "Wayang Goyang Disco"}, Buka = "Speed Coil (jalan 20)" },
	{ Uang = 500000000, Butuh = {"Garuda Es Kopi Susu"}, Buka = "Perisai Emas (kunci 120 dtk)" },
	{ Uang = 5000000000, Butuh = {"Mie Ayam Tsunami Raksasa"}, Buka = "Teleport Pulang + gelar Raja Indomie" },
}

function RebirthSystem.cekSyaratRebirth(player)
	local data = GameState.Pemain[player]
	if not data then
		return false, "Data pemain belum siap."
	end
	local level = data.Rebirth + 1
	local syarat = RebirthSystem.Syarat[level]
	if not syarat then
		return false, "Rebirth sudah maksimal (5)!"
	end
	if data.Uang < syarat.Uang then
		return false, "Rebirth " .. level .. " butuh " .. Economy.formatUang(syarat.Uang) .. "."
	end
	for _, nama in ipairs(syarat.Butuh) do
		local punya = false
		for _, slot in ipairs(data.Slot) do
			if slot and slot.Data.Nama == nama then
				punya = true
			end
		end
		if not punya then
			return false, "Rebirth " .. level .. " butuh " .. nama .. " di base!"
		end
	end
	return true, syarat
end

function RebirthSystem.lakukanRebirth(player)
	local ok, info = RebirthSystem.cekSyaratRebirth(player)
	local pesan = Remotes.ambil("BeriPesan")
	if not ok then
		pesan:FireClient(player, info)
		return
	end
	local data = GameState.Pemain[player]
	for _, slot in ipairs(data.Slot) do
		if slot and slot.Model then
			slot.Model:Destroy()
		end
	end
	data.Slot = {}
	data.Uang = GameState.Konfigurasi.UangAwal
	data.Rebirth = data.Rebirth + 1
	if data.Rebirth >= 2 then
		data.SlotMaks = GameState.Konfigurasi.SlotAwal + GameState.Konfigurasi.SlotPerLantai
	end
	data.KunciSampai = tick() + GameState.durasiKunci(data.Rebirth)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and data.Rebirth >= 3 then
		humanoid.WalkSpeed = GameState.Konfigurasi.JalanCoil
	end
	pesan:FireClient(player, "REBIRTH " .. data.Rebirth .. "! Pengali uang x" .. GameState.pengaliRebirth(data.Rebirth) .. " — " .. info.Buka)
end

function RebirthSystem.mulai()
	Remotes.ambil("AksiRebirth").OnServerEvent:Connect(function(player)
		RebirthSystem.lakukanRebirth(player)
	end)
	Remotes.ambil("AksiTeleport").OnServerEvent:Connect(function(player)
		local data = GameState.Pemain[player]
		if not data or data.Rebirth < 5 then
			Remotes.ambil("BeriPesan"):FireClient(player, "Teleport Pulang terbuka di Rebirth 5.")
			return
		end
		local character = player.Character
		local akar = character and character:FindFirstChild("HumanoidRootPart")
		if akar then
			local base = WorldBuilder.Info.Bases.Pemain
			akar.CFrame = CFrame.new(base.Posisi + Vector3.new(0, 3, 0))
			Remotes.ambil("BeriPesan"):FireClient(player, "Teleport pulang! Gelar: Raja Indomie.")
		end
	end)
end

return RebirthSystem
