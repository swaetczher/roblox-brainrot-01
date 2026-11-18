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
	JalanMemikul = 9,
	JalanCoil = 20,
	JedaOmbak = 50,
	HitungMundurOmbak = 5,
	HargaCurian = 1.5,
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

return GameState
