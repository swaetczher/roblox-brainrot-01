-- R3 rewrite terekam 2026-11-18.
-- Ancaman 3, bos telur: pecahkan telur, bos bangun dan mengejar sampai base.
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Server = ServerScriptService:WaitForChild("Server")
local CharacterData = require(Shared:WaitForChild("CharacterData"))
local GameState = require(Shared:WaitForChild("GameState"))
local WorldBuilder = require(Server:WaitForChild("WorldBuilder"))
local CharacterFactory = require(Server:WaitForChild("CharacterFactory"))
local BaseManager = require(Server:WaitForChild("BaseManager"))
local StealSystem = require(Server:WaitForChild("StealSystem"))
local Remotes = require(Server:WaitForChild("Remotes"))

local BossEggSystem = {}

local telur = nil
local bos = nil
local JARAK_TELUR_MAKS = 40
local KECEPATAN_BOS = 0.55
local JEDA_TELUR_BARU = 30

local function buatTelur()
	local arena = WorldBuilder.Info.ArenaTelur
	local model = Instance.new("Model")
	model.Name = "TelurRaksasa"
	local badan = Instance.new("Part")
	badan.Name = "Badan"
	badan.Shape = Enum.PartType.Ball
	badan.Size = Vector3.new(8, 10, 8)
	badan.Position = arena + Vector3.new(0, 5, 0)
	badan.Color = Color3.fromRGB(255, 250, 230)
	badan.Anchored = true
	badan.Material = Enum.Material.SmoothPlastic
	badan.Parent = model
	local klik = Instance.new("ClickDetector")
	klik.MaxActivationDistance = 32
	klik.Parent = badan
	model.PrimaryPart = badan
	model.Parent = Workspace
	klik.MouseClick:Connect(function(player)
		BossEggSystem.pecahkanTelur(player)
	end)
	telur = model
end

local function tidurkanBos()
	GameState.Bos.Bangun = false
	GameState.Bos.Mengejar = nil
	if bos then
		bos:SetAttribute("Tidur", true)
		bos:PivotTo(CFrame.new(WorldBuilder.Info.ArenaTelur + Vector3.new(12, 2, 0)))
	end
end

function BossEggSystem.jarakKeArena(player)
	local character = player.Character
	local akar = character and character:FindFirstChild("HumanoidRootPart")
	if not akar then
		return math.huge
	end
	local arena = WorldBuilder.Info.ArenaTelur
	return (Vector3.new(akar.Position.X, 0, akar.Position.Z) - Vector3.new(arena.X, 0, arena.Z)).Magnitude
end

function BossEggSystem.tangkapPemain(player)
	if telur then
		telur:PivotTo(CFrame.new(WorldBuilder.Info.ArenaTelur + Vector3.new(0, 5, 0)))
	end
	tidurkanBos()
	player:LoadCharacter()
	Remotes.ambil("BeriPesan"):FireClient(player, "Bos menangkapmu! Telur kembali ke sarang.")
end

function BossEggSystem.pecahkanTelur(player)
	if GameState.Bos.Bangun then
		return
	end
	if not telur then
		return
	end
	local data = GameState.Pemain[player]
	if not data then
		return
	end
	if BossEggSystem.jarakKeArena(player) > JARAK_TELUR_MAKS then
		Remotes.ambil("BeriPesan"):FireClient(player, "Terlalu jauh dari arena telur bos! Dekati dulu.")
		return
	end
	if data.Membawa then
		Remotes.ambil("BeriPesan"):FireClient(player, "Tanganmu penuh! Taruh dulu bawaanmu di base.")
		return
	end
	GameState.Bos.Bangun = true
	GameState.Bos.Mengejar = player
	if bos then
		bos:SetAttribute("Tidur", false)
	end
	Remotes.ambil("BeriPesan"):FireAllClients("BOS BANGUN! Bapak Mie Ayam Raksasa mengejar " .. player.Name .. "!")
	local modelTelur = telur
	StealSystem.mulaiBawa(player, modelTelur, "Telur", nil, function()
		BossEggSystem.tetaskanTelur(player)
	end, function()
		if telur == modelTelur then
			telur:PivotTo(CFrame.new(WorldBuilder.Info.ArenaTelur + Vector3.new(0, 5, 0)))
		end
		tidurkanBos()
	end)
	task.spawn(function()
		while GameState.Bos.Bangun do
			if not bos then
				tidurkanBos()
				break
			end
			local target = GameState.Bos.Mengejar
			local character = target and target.Character
			local akar = character and character:FindFirstChild("HumanoidRootPart")
			if not akar then
				tidurkanBos()
				break
			end
			local posisiBos = bos:GetPivot().Position
			local arah = akar.Position - posisiBos
			local jarak = arah.Magnitude
			if jarak < 5 then
				BossEggSystem.tangkapPemain(target)
				break
			end
			local gerak = arah.Unit * KECEPATAN_BOS
			bos:PivotTo(CFrame.new(posisiBos + Vector3.new(gerak.X, 0, gerak.Z)))
			task.wait(0.1)
		end
	end)
end

function BossEggSystem.tetaskanTelur(player)
	local data = GameState.Pemain[player]
	if not data then
		return
	end
	local gulir = math.random(100)
	local rarity = "Mythic"
	if gulir <= 30 then
		rarity = "Secret"
	end
	local dataKarakter = CharacterData.ambilDariRarity(rarity)
	local mutasi = CharacterData.ambilMutasiAcak()
	local model = CharacterFactory.buatBrainrot(dataKarakter, mutasi, nil, 1)
	model.Parent = Workspace
	local entri = { Model = model, Data = dataKarakter, Mutasi = mutasi, Trait = nil }
	if BaseManager.taruhDiBase(player, entri) then
		Remotes.ambil("BeriPesan"):FireClient(player, "Telur menetas jadi " .. dataKarakter.Nama .. " (" .. rarity .. ")!")
	else
		model:Destroy()
		Remotes.ambil("BeriPesan"):FireClient(player, "Base penuh! Hasil tetasan hilang.")
	end
	telur = nil
	tidurkanBos()
	task.delay(JEDA_TELUR_BARU, function()
		if not telur then
			buatTelur()
		end
	end)
end

function BossEggSystem.mulai()
	buatTelur()
	local dataBos = { Nama = "Bapak Mie Ayam Raksasa", Rarity = "Secret", Harga = 0, PerDetik = 0, Warna = Color3.fromRGB(200, 60, 60), Bentuk = "Bulat" }
	bos = CharacterFactory.buatBrainrot(dataBos, { Nama = "Normal", Pengali = 1 }, nil, 3)
	bos:SetAttribute("Tidur", true)
	bos:PivotTo(CFrame.new(WorldBuilder.Info.ArenaTelur + Vector3.new(12, 2, 0)))
	bos.Parent = Workspace
	Remotes.ambil("AksiTelur").OnServerEvent:Connect(function(player)
		BossEggSystem.pecahkanTelur(player)
	end)
end

return BossEggSystem
