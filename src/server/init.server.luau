-- R3 rewrite terekam 2026-11-18.
-- Bootstrap "CURI BRAINROT: BANJIR MIE AYAM": bangun dunia, nyalakan semua sistem.
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local Server = ServerScriptService:WaitForChild("Server")

local Remotes = require(Server:WaitForChild("Remotes"))
local WorldBuilder = require(Server:WaitForChild("WorldBuilder"))
local BaseManager = require(Server:WaitForChild("BaseManager"))
local BeltSpawner = require(Server:WaitForChild("BeltSpawner"))
local StealSystem = require(Server:WaitForChild("StealSystem"))
local WaveSystem = require(Server:WaitForChild("WaveSystem"))
local BossEggSystem = require(Server:WaitForChild("BossEggSystem"))
local RebirthSystem = require(Server:WaitForChild("RebirthSystem"))
local BotPemain = require(Server:WaitForChild("BotPemain"))

WorldBuilder.bangun()
BaseManager.SaatTaruh = StealSystem.daftarkanBrainrotBase
BaseManager.mulai()
StealSystem.mulai()
BeltSpawner.mulai()
WaveSystem.mulai()
BossEggSystem.mulai()
RebirthSystem.mulai()
BotPemain.mulai()

Players.PlayerAdded:Connect(function(player)
	BaseManager.buatDataPemain(player)
end)
Players.PlayerRemoving:Connect(function(player)
	BaseManager.hapusDataPemain(player)
end)
for _, player in ipairs(Players:GetPlayers()) do
	BaseManager.buatDataPemain(player)
end

print("CURI BRAINROT: BANJIR MIE AYAM jalan — 12 brainrot, 6 rarity, 3 ancaman, 5 rebirth, 3 bot.")
