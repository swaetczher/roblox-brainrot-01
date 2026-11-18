-- SATU tempat state server: uang, slot base, kunci, rebirth, status ombak.
local GameState = {}

GameState.Konfigurasi = {
	UangAwal = 100,
	SlotAwal = 8,
	SlotPerLantai = 4,
	KunciAwal = 60,
	KunciPerRebirth = 10,
	KunciPerisai = 120,
	JalanNormal = 16,
	-- Pikul: 16 -> 9, alias -43,75%.
	JalanMemikul = 9,
	JalanCoil = 20,
	JedaOmbak = 50,
	HitungMundurOmbak = 5,
	HargaCurian = 1.5,
	JarakAmanParit = 10,
	JarakAmanBase = 24,
}

GameState.Pemain = {}
GameState.Bot = {}
GameState.Ombak = { Status = "Tenang", Sisa = 50, Kecepatan = "Lambat", Z = -180 }
GameState.Bos = { Bangun = false, Mengejar = nil }

function GameState.dataBaru()
	return {
		Uang = GameState.Konfigurasi.UangAwal,
		Slot = {},
		SlotMaks = GameState.Konfigurasi.SlotAwal,
		KunciSampai = 0,
		Rebirth = 0,
		Membawa = nil,
	}
end

function GameState.pengaliRebirth(level)
	if level < 0 then
		return 1
	end
	if level > 5 then
		return 6
	end
	return level + 1
end

function GameState.durasiKunci(level)
	if level >= 4 then
		return GameState.Konfigurasi.KunciPerisai
	end
	return GameState.Konfigurasi.KunciAwal + level * GameState.Konfigurasi.KunciPerRebirth
end

function GameState.baseTerkunci(data)
	if not data then
		return false
	end
	return tick() < data.KunciSampai
end

-- Sisa detik kunci, 0 kalau tidak terkunci. Dipakai HUD dan pesan kunci.
function GameState.sisaKunci(data)
	if not GameState.baseTerkunci(data) then
		return 0
	end
	return math.floor(data.KunciSampai - tick())
end

function GameState.resetOmbak()
	GameState.Ombak.Status = "Tenang"
	GameState.Ombak.Sisa = GameState.Konfigurasi.JedaOmbak
	GameState.Ombak.Z = -180
end

return GameState
