-- R3 rewrite terekam 2026-11-18.
-- Hitung uang: format tampilan Indonesia + rumus income brainrot.
local Economy = {}

function Economy.formatUang(nilai)
	if nilai < 0 then
		return "-" .. Economy.formatUang(-nilai)
	end
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

function Economy.hitungIncome(data, pengaliMutasi, daftarTrait, pengaliRebirth)
	local jumlahTrait = 0
	if daftarTrait then
		for _, trait in ipairs(daftarTrait) do
			if trait and trait.Tambah then
				jumlahTrait = jumlahTrait + trait.Tambah
			end
		end
	end
	local rebirth = pengaliRebirth or 1
	if rebirth < 1 then
		rebirth = 1
	end
	return data.PerDetik * (pengaliMutasi + jumlahTrait) * rebirth
end

function Economy.hargaSalip(harga)
	return math.floor(harga * 1.5)
end

return Economy
