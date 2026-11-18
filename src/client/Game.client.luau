-- R3 rewrite terekam 2026-11-18.
-- HUD "CURI BRAINROT: BANJIR MIE AYAM".
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local updateHUD = remotes:WaitForChild("UpdateHUD")
local beriPesan = remotes:WaitForChild("BeriPesan")

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function buatLabel(nama, ukuran, posisi, teks, warna)
	local label = Instance.new("TextLabel")
	label.Name = nama
	label.Size = ukuran
	label.Position = posisi
	label.BackgroundTransparency = 0.4
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	label.TextColor3 = warna or Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = teks
	label.Parent = gui
	return label
end

local function buatTombol(nama, ukuran, posisi, teks, warna)
	local tombol = Instance.new("TextButton")
	tombol.Name = nama
	tombol.Size = ukuran
	tombol.Position = posisi
	tombol.BackgroundColor3 = warna
	tombol.TextColor3 = Color3.fromRGB(255, 255, 255)
	tombol.Font = Enum.Font.GothamBold
	tombol.TextScaled = true
	tombol.Text = teks
	tombol.Parent = gui
	return tombol
end

local judul = buatLabel("Judul", UDim2.new(0.6, 0, 0.07, 0), UDim2.new(0.2, 0, 0.02, 0), "CURI BRAINROT: BANJIR MIE AYAM", Color3.fromRGB(255, 210, 40))
local uang = buatLabel("Uang", UDim2.new(0.4, 0, 0.09, 0), UDim2.new(0.3, 0, 0.10, 0), "$100", Color3.fromRGB(120, 255, 120))
local perDetik = buatLabel("PerDetik", UDim2.new(0.5, 0, 0.05, 0), UDim2.new(0.25, 0, 0.20, 0), "+$0/dtk | 12 BRAINROT - 6 RARITY - 3 ANCAMAN", Color3.fromRGB(255, 255, 255))
local ombak = buatLabel("Ombak", UDim2.new(0.5, 0, 0.06, 0), UDim2.new(0.25, 0, 0.26, 0), "BANJIR MIE: 50 dtk - Tenang", Color3.fromRGB(255, 200, 80))
local hint = buatLabel("Hint", UDim2.new(0.56, 0, 0.05, 0), UDim2.new(0.22, 0, 0.33, 0), "Klik brainrot di karpet merah untuk BELI", Color3.fromRGB(200, 220, 255))
local slot = buatLabel("Slot", UDim2.new(0.3, 0, 0.05, 0), UDim2.new(0.02, 0, 0.85, 0), "Base: 0/8 brainrot", Color3.fromRGB(255, 255, 255))
local pesan = buatLabel("Pesan", UDim2.new(0.6, 0, 0.06, 0), UDim2.new(0.2, 0, 0.86, 0), "Selamat datang! Beli brainrot pertamamu.", Color3.fromRGB(255, 255, 255))

local tombolKunci = buatTombol("TombolKunci", UDim2.new(0.18, 0, 0.07, 0), UDim2.new(0.78, 0, 0.35, 0), "KUNCI BASE", Color3.fromRGB(200, 40, 40))
local tombolRebirth = buatTombol("TombolRebirth", UDim2.new(0.18, 0, 0.07, 0), UDim2.new(0.78, 0, 0.44, 0), "REBIRTH", Color3.fromRGB(140, 60, 220))
local tombolTampar = buatTombol("TombolTampar", UDim2.new(0.18, 0, 0.07, 0), UDim2.new(0.78, 0, 0.53, 0), "TAMPAR", Color3.fromRGB(220, 140, 40))
local tombolTelur = buatTombol("TombolTelur", UDim2.new(0.18, 0, 0.07, 0), UDim2.new(0.78, 0, 0.62, 0), "PECAHKAN TELUR BOS", Color3.fromRGB(255, 210, 40))
local tombolTeleport = buatTombol("TombolTeleport", UDim2.new(0.18, 0, 0.07, 0), UDim2.new(0.78, 0, 0.71, 0), "TELEPORT PULANG", Color3.fromRGB(40, 160, 220))
tombolTeleport.Visible = false

local function formatUang(nilai)
	if nilai >= 1000000000000 then
		return string.format("$%.2f T", nilai / 1000000000000)
	elseif nilai >= 1000000000 then
		return string.format("$%.2f M", nilai / 1000000000)
	elseif nilai >= 1000000 then
		return string.format("$%.2f jt", nilai / 1000000)
	elseif nilai >= 1000 then
		return string.format("$%.1f rb", nilai / 1000)
	else
		return string.format("$%d", math.floor(nilai))
	end
end

updateHUD.OnClientEvent:Connect(function(uangBaru, perDetikBaru, statusOmbak, sisaOmbak, kecepatanOmbak, kunciSisa, rebirth, terisi, slotMaks)
	uang.Text = formatUang(uangBaru)
	perDetik.Text = "+" .. formatUang(perDetikBaru) .. "/dtk | Rebirth " .. rebirth .. " | 12 BRAINROT - 6 RARITY - 3 ANCAMAN"
	if statusOmbak == "Sirene" then
		ombak.Text = "SIRENE! Banjir mie " .. kecepatanOmbak .. " dalam " .. sisaOmbak .. " dtk!"
		ombak.TextColor3 = Color3.fromRGB(255, 60, 60)
	elseif statusOmbak == "Banjir" then
		ombak.Text = "BANJIR MIE " .. kecepatanOmbak .. "! Lari ke base atau parit!"
		ombak.TextColor3 = Color3.fromRGB(255, 60, 60)
	else
		ombak.Text = "BANJIR MIE: " .. sisaOmbak .. " dtk - Tenang (" .. kecepatanOmbak .. ")"
		ombak.TextColor3 = Color3.fromRGB(255, 200, 80)
	end
	if kunciSisa > 0 then
		tombolKunci.Text = "TERKUNCI " .. kunciSisa .. " dtk"
	else
		tombolKunci.Text = "KUNCI BASE"
	end
	slot.Text = "Base: " .. terisi .. "/" .. slotMaks .. " brainrot"
	if rebirth >= 5 then
		tombolTeleport.Visible = true
	end
end)

beriPesan.OnClientEvent:Connect(function(teks)
	pesan.Text = teks
end)

local terakhirKlik = 0
local function hubungkanTombol(tombol, namaRemote)
	tombol.MouseButton1Click:Connect(function()
		local sekarang = tick()
		if sekarang - terakhirKlik < 0.5 then
			return
		end
		terakhirKlik = sekarang
		remotes:WaitForChild(namaRemote):FireServer()
	end)
end

hubungkanTombol(tombolKunci, "AksiKunci")
hubungkanTombol(tombolRebirth, "AksiRebirth")
hubungkanTombol(tombolTampar, "AksiTampar")
hubungkanTombol(tombolTelur, "AksiTelur")
hubungkanTombol(tombolTeleport, "AksiTeleport")
