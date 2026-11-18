-- Bangun model brainrot dari Part: badan + kepala + mata + topi rarity + tag nama.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local CharacterData = require(Shared:WaitForChild("CharacterData"))
local Economy = require(Shared:WaitForChild("Economy"))

local CharacterFactory = {}

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

function CharacterFactory.buatBrainrot(data, mutasi, trait, skala)
	skala = skala or 1
	mutasi = mutasi or { Nama = "Normal", Pengali = 1 }
	local traits = {}
	if trait then
		table.insert(traits, trait)
	end
	local income = Economy.hitungIncome(data, mutasi.Pengali, traits, 1)
	local warnaRarity = CharacterData.RarityWarna[data.Rarity]

	local model = Instance.new("Model")
	model.Name = data.Nama

	local badan = buatPart("Badan", Vector3.new(4, 3, 3) * skala, Vector3.new(0, 2, 0), data.Warna, model)
	if data.Bentuk == "Bulat" then
		badan.Shape = Enum.PartType.Ball
	end
	local kepala = buatPart("Kepala", Vector3.new(2.5, 2.5, 2.5) * skala, Vector3.new(0, 4.5, 0) * skala, data.Warna, model)
	kepala.Shape = Enum.PartType.Ball
	local mataKiri = buatPart("MataKiri", Vector3.new(0.5, 0.7, 0.5) * skala, Vector3.new(-0.6, 4.7, -1.3) * skala, Color3.fromRGB(20, 20, 20), model)
	mataKiri.Shape = Enum.PartType.Ball
	local mataKanan = buatPart("MataKanan", Vector3.new(0.5, 0.7, 0.5) * skala, Vector3.new(0.6, 4.7, -1.3) * skala, Color3.fromRGB(20, 20, 20), model)
	mataKanan.Shape = Enum.PartType.Ball
	local topi
	if data.Bentuk == "Tinggi" then
		topi = buatPart("Topi", Vector3.new(1.5, 2.5, 1.5) * skala, Vector3.new(0, 6.8, 0) * skala, warnaRarity, model)
		topi.Shape = Enum.PartType.Cylinder
	elseif data.Bentuk == "Kotak" then
		topi = buatPart("Topi", Vector3.new(3, 1, 3) * skala, Vector3.new(0, 6.2, 0) * skala, warnaRarity, model)
	else
		topi = buatPart("Topi", Vector3.new(2, 2, 2) * skala, Vector3.new(0, 6.2, 0) * skala, warnaRarity, model)
		topi.Shape = Enum.PartType.Ball
	end
	topi.Material = Enum.Material.Neon

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 240, 0, 110)
	gui.StudsOffsetWorldSpace = Vector3.new(0, 5, 0) * skala
	gui.AlwaysOnTop = true
	gui.Parent = kepala
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 0.4
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	local barisMutasi = data.Rarity
	if mutasi.Nama ~= "Normal" then
		barisMutasi = barisMutasi .. " " .. mutasi.Nama .. " x" .. tostring(mutasi.Pengali)
	end
	if trait then
		barisMutasi = barisMutasi .. " +" .. trait.Nama
	end
	label.Text = data.Nama .. "\n" .. barisMutasi .. "\n" .. Economy.formatUang(income) .. "/dtk\nHarga " .. Economy.formatUang(data.Harga)
	label.Parent = gui

	local klik = Instance.new("ClickDetector")
	klik.MaxActivationDistance = 32
	klik.Parent = badan

	model:SetAttribute("Nama", data.Nama)
	model:SetAttribute("Rarity", data.Rarity)
	model:SetAttribute("Harga", data.Harga)
	model:SetAttribute("PerDetik", data.PerDetik)
	model:SetAttribute("Mutasi", mutasi.Nama)
	model:SetAttribute("PengaliMutasi", mutasi.Pengali)
	model:SetAttribute("Trait", trait and trait.Nama or "")
	model:SetAttribute("DiBase", false)
	model:SetAttribute("Jatuh", false)
	model.PrimaryPart = badan
	return model
end

function CharacterFactory.buatBot(nama, warna)
	local model = Instance.new("Model")
	model.Name = nama
	local badan = buatPart("Badan", Vector3.new(3, 3, 2), Vector3.new(0, 2, 0), warna, model)
	local kepala = buatPart("Kepala", Vector3.new(2, 2, 2), Vector3.new(0, 4.5, 0), Color3.fromRGB(255, 220, 170), model)
	kepala.Shape = Enum.PartType.Ball
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 200, 0, 50)
	gui.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = kepala
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 0.4
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = nama .. "\nBOT PENCURI"
	label.Parent = gui
	model.PrimaryPart = badan
	return model
end

return CharacterFactory
