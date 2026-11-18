-- Bangun dunia prosedural: 4 base, karpet merah, 6 zona, 3 parit, arena telur bos.
-- Posisi semua elemen ditulis sebagai konstanta bernama supaya mudah dicek di peta.
local WorldBuilder = {}

WorldBuilder.Info = nil

local JUMLAH_KARPET = 20
local PANJANG_KARPET = 12
local Z_KARPET_AWAL = -114

local function buatPart(nama, ukuran, posisi, warna, parent)
	local part = Instance.new("Part")
	part.Name = nama
	part.Size = ukuran
	part.Position = posisi
	part.Color = warna
	part.Anchored = true
	part.Material = Enum.Material.SmoothPlastic
	part.Parent = parent
	return part
end

local function buatLabel(parent, teks, warna)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 220, 0, 60)
	gui.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = parent
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 0.5
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	label.TextColor3 = warna
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = teks
	label.Parent = gui
	return gui
end

local function buatBase(folder, kunci, tengah, warna, namaTampil)
	local base = {}
	base.Posisi = tengah
	base.SlotPos = {}
	-- 3 baris x 4 kolom = 12 posisi slot, cukup untuk SlotMaks tertinggi (8 + 4).
	for baris = 1, 3 do
		for kolom = 1, 4 do
			table.insert(base.SlotPos, tengah + Vector3.new(-15 + (kolom - 1) * 10, 2, -12 + (baris - 1) * 10))
		end
	end
	buatPart("Lantai" .. kunci, Vector3.new(44, 1, 44), tengah + Vector3.new(0, 0.5, 0), warna, folder)
	buatPart("DindingBelakang" .. kunci, Vector3.new(44, 5, 1), tengah + Vector3.new(0, 2.5, -21.5), warna, folder)
	buatPart("DindingKiri" .. kunci, Vector3.new(1, 5, 44), tengah + Vector3.new(-21.5, 2.5, 0), warna, folder)
	buatPart("DindingKanan" .. kunci, Vector3.new(1, 5, 44), tengah + Vector3.new(21.5, 2.5, 0), warna, folder)
	local gerbang = buatPart("GerbangLaser" .. kunci, Vector3.new(16, 6, 1), tengah + Vector3.new(0, 3, 21.5), Color3.fromRGB(255, 40, 40), folder)
	gerbang.Transparency = 0.4
	gerbang.Material = Enum.Material.Neon
	base.Gerbang = gerbang
	buatLabel(gerbang, namaTampil, Color3.fromRGB(255, 255, 255))
	return base
end

function WorldBuilder.bangun()
	if WorldBuilder.Info then
		return WorldBuilder.Info
	end
	local Workspace = game:GetService("Workspace")
	local folder = Instance.new("Folder")
	folder.Name = "Dunia"
	folder.Parent = Workspace

	-- Karpet merah: jalur belt dari ujung jauh (Secret, Z -114) ke base pemain (Z +114).
	for i = 0, JUMLAH_KARPET - 1 do
		buatPart("Karpet" .. i, Vector3.new(14, 0.5, 12), Vector3.new(0, 0.25, Z_KARPET_AWAL + i * PANJANG_KARPET), Color3.fromRGB(200, 30, 40), folder)
	end

	-- 6 zona rarity di sisi belt: makin jauh dari base, makin langka.
	-- Zona Z positif di kanan belt (X +30), zona Z negatif di kiri (X -30).
	local zona = {
		{ Nama = "ZONA Common", Z = 100, Warna = Color3.fromRGB(175, 175, 175) },
		{ Nama = "ZONA Rare", Z = 60, Warna = Color3.fromRGB(80, 200, 90) },
		{ Nama = "ZONA Epic", Z = 20, Warna = Color3.fromRGB(70, 130, 255) },
		{ Nama = "ZONA Legendary", Z = -20, Warna = Color3.fromRGB(170, 80, 255) },
		{ Nama = "ZONA Mythic", Z = -60, Warna = Color3.fromRGB(255, 120, 40) },
		{ Nama = "ZONA Secret", Z = -100, Warna = Color3.fromRGB(255, 210, 40) },
	}
	for _, satu in ipairs(zona) do
		local sisi = 30
		if satu.Z < 0 then
			sisi = -30
		end
		local pad = buatPart("Zona" .. satu.Nama, Vector3.new(18, 0.5, 18), Vector3.new(sisi, 0.25, satu.Z), satu.Warna, folder)
		buatLabel(pad, satu.Nama, Color3.fromRGB(255, 255, 255))
	end

	-- 3 parit aman dari banjir mie (radius aman 10 stud, lihat WaveSystem.cekParitAman).
	local parit = {
		Vector3.new(-42, 0, -40),
		Vector3.new(42, 0, 40),
		Vector3.new(-42, 0, 80),
	}
	for i, posisi in ipairs(parit) do
		local pad = buatPart("Parit" .. i, Vector3.new(16, 0.5, 16), posisi + Vector3.new(0, 0.25, 0), Color3.fromRGB(40, 80, 140), folder)
		buatLabel(pad, "PARIT AMAN", Color3.fromRGB(255, 255, 255))
	end

	-- Arena telur bos di ujung jauh.
	local arenaPos = Vector3.new(0, 0, -170)
	buatPart("LantaiArena", Vector3.new(44, 1, 44), arenaPos + Vector3.new(0, 0.5, 0), Color3.fromRGB(120, 90, 60), folder)
	local tanda = buatPart("TandaArena", Vector3.new(20, 0.5, 6), arenaPos + Vector3.new(0, 1, 18), Color3.fromRGB(255, 210, 40), folder)
	buatLabel(tanda, "ARENA TELUR BOS", Color3.fromRGB(255, 255, 255))

	-- 4 base: 1 pemain + 3 bot.
	local bases = {}
	bases.Pemain = buatBase(folder, "Pemain", Vector3.new(0, 0, 150), Color3.fromRGB(70, 130, 255), "BASE KAMU")
	bases.Bot1 = buatBase(folder, "Bot1", Vector3.new(-150, 0, 150), Color3.fromRGB(255, 120, 180), "BASE BOT SARI")
	bases.Bot2 = buatBase(folder, "Bot2", Vector3.new(150, 0, 150), Color3.fromRGB(80, 200, 255), "BASE BOT BUDI")
	bases.Bot3 = buatBase(folder, "Bot3", Vector3.new(-150, 0, -150), Color3.fromRGB(140, 255, 140), "BASE BOT CICI")

	-- Spawn pemain di base sendiri.
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnPemain"
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.Position = Vector3.new(0, 0.5, 168)
	spawn.Neutral = true
	spawn.AllowTeamChangeOnTouch = false
	spawn.Parent = folder

	-- Pohon dekorasi di tepi arena (posisi deterministik, tanpa randomseed).
	-- Dijaga keluar dari koridor belt (|X| <= 60) dan area base (|Z| <= 130).
	for i = 1, 24 do
		local x = ((i * 137) % 460) - 230
		local z = ((i * 211) % 420) - 210
		if math.abs(x) > 60 or math.abs(z) > 130 then
			local batang = buatPart("Pohon" .. i, Vector3.new(2, 7, 2), Vector3.new(x, 3.5, z), Color3.fromRGB(120, 80, 40), folder)
			batang.Shape = Enum.PartType.Cylinder
			local daun = buatPart("Daun" .. i, Vector3.new(7, 7, 7), Vector3.new(x, 10, z), Color3.fromRGB(50, 160, 70), folder)
			daun.Shape = Enum.PartType.Ball
		end
	end

	WorldBuilder.Info = {
		Bases = bases,
		Parit = parit,
		ArenaTelur = arenaPos,
		BeltAwal = Vector3.new(0, 2, -114),
		BeltAkhir = Vector3.new(0, 2, 114),
	}
	return WorldBuilder.Info
end

return WorldBuilder
