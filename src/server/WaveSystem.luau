-- Ancaman 2, banjir mie: sirene + hitung mundur, lalu ombak menyapu lintasan.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Server = ServerScriptService:WaitForChild("Server")
local GameState = require(Shared:WaitForChild("GameState"))
local WorldBuilder = require(Server:WaitForChild("WorldBuilder"))
local StealSystem = require(Server:WaitForChild("StealSystem"))
local Remotes = require(Server:WaitForChild("Remotes"))

local WaveSystem = {}

local kecepatanNama = {"Lambat", "Sedang", "Cepat", "Kilat"}
local durasiOmbak = { Lambat = 10, Sedang = 7, Cepat = 5, Kilat = 3 }
local LANGKAH_OMBAK = 40
local Z_OMBAK_AWAL = -180
local Z_OMBAK_AKHIR = 180

function WaveSystem.cekParitAman(posisi)
	for _, parit in ipairs(WorldBuilder.Info.Parit) do
		local jarak = (Vector3.new(posisi.X, 0, posisi.Z) - Vector3.new(parit.X, 0, parit.Z)).Magnitude
		if jarak < GameState.Konfigurasi.JarakAmanParit then
			return true
		end
	end
	return false
end

function WaveSystem.cekDiBase(posisi)
	for _, base in pairs(WorldBuilder.Info.Bases) do
		local jarak = (Vector3.new(posisi.X, 0, posisi.Z) - Vector3.new(base.Posisi.X, 0, base.Posisi.Z)).Magnitude
		if jarak < GameState.Konfigurasi.JarakAmanBase then
			return true
		end
	end
	return false
end

function WaveSystem.cekKorban(batasZ)
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		local akar = character and character:FindFirstChild("HumanoidRootPart")
		if akar and akar.Position.Z < batasZ + 6 then
			if not WaveSystem.cekParitAman(akar.Position) and not WaveSystem.cekDiBase(akar.Position) then
				StealSystem.jatuhkanBawaan(player)
				player:LoadCharacter()
				Remotes.ambil("BeriPesan"):FireClient(player, "Kena banjir mie! Kamu kembali ke base, bawaanmu jatuh.")
			end
		end
	end
end

function WaveSystem.luncurkanTsunami(kecepatan)
	GameState.Ombak.Status = "Banjir"
	local durasi = durasiOmbak[kecepatan] or 7
	local ombak = Instance.new("Part")
	ombak.Name = "OmbakMie"
	ombak.Size = Vector3.new(320, 24, 12)
	ombak.Position = Vector3.new(0, 12, Z_OMBAK_AWAL)
	ombak.Anchored = true
	ombak.CanCollide = false
	ombak.Transparency = 0.35
	ombak.Color = Color3.fromRGB(255, 200, 80)
	ombak.Material = Enum.Material.Neon
	ombak.Parent = Workspace
	for i = 1, LANGKAH_OMBAK do
		local z = Z_OMBAK_AWAL + ((Z_OMBAK_AKHIR - Z_OMBAK_AWAL) * i / LANGKAH_OMBAK)
		ombak.Position = Vector3.new(0, 12, z)
		GameState.Ombak.Z = z
		WaveSystem.cekKorban(z)
		task.wait(durasi / LANGKAH_OMBAK)
	end
	WaveSystem.cekKorban(Z_OMBAK_AKHIR)
	ombak:Destroy()
	GameState.Ombak.Z = Z_OMBAK_AWAL
end

function WaveSystem.mulai()
	task.spawn(function()
		while true do
			GameState.resetOmbak()
			for i = GameState.Konfigurasi.JedaOmbak, 1, -1 do
				GameState.Ombak.Sisa = i
				task.wait(1)
			end
			local kecepatan = kecepatanNama[math.random(1, #kecepatanNama)]
			GameState.Ombak.Kecepatan = kecepatan
			GameState.Ombak.Status = "Sirene"
			Remotes.ambil("BeriPesan"):FireAllClients("SIRENE! Banjir mie " .. kecepatan .. " datang! Lari ke base atau parit!")
			for i = GameState.Konfigurasi.HitungMundurOmbak, 1, -1 do
				GameState.Ombak.Sisa = i
				task.wait(1)
			end
			WaveSystem.luncurkanTsunami(kecepatan)
		end
	end)
end

return WaveSystem
