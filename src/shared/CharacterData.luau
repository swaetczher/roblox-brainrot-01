-- Data 12 karakter brainrot orisinal "CURI BRAINROT: BANJIR MIE AYAM".
-- Harga dan $/detik ikut skala Steal a Brainrot; payback 25-333 detik.
-- Rarity di-cache per nama supaya ambilDariRarity tidak memindai Daftar tiap spawn.
local CharacterData = {}

CharacterData.RarityUrutan = {"Common", "Rare", "Epic", "Legendary", "Mythic", "Secret"}

CharacterData.RarityWarna = {
	Common = Color3.fromRGB(175, 175, 175),
	Rare = Color3.fromRGB(80, 200, 90),
	Epic = Color3.fromRGB(70, 130, 255),
	Legendary = Color3.fromRGB(170, 80, 255),
	Mythic = Color3.fromRGB(255, 120, 40),
	Secret = Color3.fromRGB(255, 210, 40),
}

CharacterData.MutasiPeluang = {
	{ Nama = "Emas", Pengali = 1.25, Peluang = 8 },
	{ Nama = "Berlian", Pengali = 1.5, Peluang = 4 },
	{ Nama = "Kilat", Pengali = 6, Peluang = 2 },
	{ Nama = "Pelangi", Pengali = 10, Peluang = 1 },
	{ Nama = "Hantu", Pengali = 12, Peluang = 1 },
}

CharacterData.TraitPeluang = {
	{ Nama = "Pedas", Tambah = 5, Peluang = 10 },
	{ Nama = "Manis", Tambah = 3, Peluang = 10 },
	{ Nama = "Asin", Tambah = 2, Peluang = 10 },
}

CharacterData.Daftar = {
	{ Nama = "Tahu Bulat Terbang", Rarity = "Common", Harga = 25, PerDetik = 1, Warna = Color3.fromRGB(240, 220, 150), Bentuk = "Bulat" },
	{ Nama = "Es Teh Manis Menangis", Rarity = "Common", Harga = 250, PerDetik = 3, Warna = Color3.fromRGB(200, 120, 60), Bentuk = "Tinggi" },
	{ Nama = "Ayam Geprek Joget", Rarity = "Rare", Harga = 2000, PerDetik = 15, Warna = Color3.fromRGB(255, 90, 60), Bentuk = "Kotak" },
	{ Nama = "Kucing Oren Barista", Rarity = "Rare", Harga = 5000, PerDetik = 40, Warna = Color3.fromRGB(255, 165, 0), Bentuk = "Kotak" },
	{ Nama = "Baso Aci Raksasa", Rarity = "Epic", Harga = 10000, PerDetik = 75, Warna = Color3.fromRGB(230, 230, 230), Bentuk = "Bulat" },
	{ Nama = "Nasi Padang Terbang", Rarity = "Epic", Harga = 25000, PerDetik = 150, Warna = Color3.fromRGB(255, 255, 255), Bentuk = "Tinggi" },
	{ Nama = "Komodo Naik Skuter", Rarity = "Legendary", Harga = 100000, PerDetik = 500, Warna = Color3.fromRGB(60, 160, 80), Bentuk = "Kotak" },
	{ Nama = "Wayang Goyang Disco", Rarity = "Legendary", Harga = 300000, PerDetik = 1250, Warna = Color3.fromRGB(150, 60, 200), Bentuk = "Tinggi" },
	{ Nama = "Garuda Es Kopi Susu", Rarity = "Mythic", Harga = 2500000, PerDetik = 7500, Warna = Color3.fromRGB(120, 80, 50), Bentuk = "Bulat" },
	{ Nama = "Tuyul Bawa Koper Emas", Rarity = "Mythic", Harga = 5000000, PerDetik = 16000, Warna = Color3.fromRGB(255, 210, 40), Bentuk = "Kotak" },
	{ Nama = "Mie Ayam Tsunami Raksasa", Rarity = "Secret", Harga = 250000000, PerDetik = 1000000, Warna = Color3.fromRGB(255, 200, 80), Bentuk = "Bulat" },
	{ Nama = "Raja Indomie Goreng Abadi", Rarity = "Secret", Harga = 1000000000, PerDetik = 10000000, Warna = Color3.fromRGB(220, 40, 40), Bentuk = "Tinggi" },
}

-- Cache per rarity, dibangun sekali saat pertama dipakai.
local perRarity = nil
local function bangunCacheRarity()
	if perRarity then
		return
	end
	perRarity = {}
	for _, data in ipairs(CharacterData.Daftar) do
		perRarity[data.Rarity] = perRarity[data.Rarity] or {}
		table.insert(perRarity[data.Rarity], data)
	end
end

function CharacterData.ambilDariRarity(rarity)
	bangunCacheRarity()
	local cocok = perRarity[rarity]
	if not cocok or #cocok == 0 then
		return nil
	end
	return cocok[math.random(1, #cocok)]
end

function CharacterData.jumlahPerRarity(rarity)
	bangunCacheRarity()
	local cocok = perRarity[rarity]
	if not cocok then
		return 0
	end
	return #cocok
end

function CharacterData.ambilAcak()
	local gulir = math.random(100)
	if gulir <= 40 then
		return CharacterData.Daftar[math.random(1, 2)]
	elseif gulir <= 70 then
		return CharacterData.Daftar[math.random(3, 4)]
	elseif gulir <= 88 then
		return CharacterData.Daftar[math.random(5, 6)]
	elseif gulir <= 96 then
		return CharacterData.Daftar[math.random(7, 8)]
	elseif gulir <= 99 then
		return CharacterData.Daftar[math.random(9, 10)]
	else
		return CharacterData.Daftar[math.random(11, 12)]
	end
end

-- Gulir 1-100 melawan peluang kumulatif; di luar total peluang = Normal.
-- Total peluang mutasi 16/100, jadi 84% spawn tetap Normal.
function CharacterData.ambilMutasiAcak()
	local gulir = math.random(100)
	local jumlah = 0
	for _, mutasi in ipairs(CharacterData.MutasiPeluang) do
		jumlah = jumlah + mutasi.Peluang
		if gulir <= jumlah then
			return mutasi
		end
	end
	return { Nama = "Normal", Pengali = 1 }
end

-- Total peluang trait 30/100; 70% spawn tanpa trait.
function CharacterData.ambilTraitAcak()
	local gulir = math.random(100)
	local jumlah = 0
	for _, trait in ipairs(CharacterData.TraitPeluang) do
		jumlah = jumlah + trait.Peluang
		if gulir <= jumlah then
			return trait
		end
	end
	return nil
end

return CharacterData
