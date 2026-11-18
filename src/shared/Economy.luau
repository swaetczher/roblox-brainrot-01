-- Hitung uang: format tampilan Indonesia + rumus income brainrot.
local Economy = {}

function Economy.formatUang(nilai)
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

-- Rumus komunitas terverifikasi: base x (mutasi + semua trait) x pengali rebirth.
-- Trait bersifat ADITIF terhadap pengali, bukan pengali berlapis.
function Economy.hitungIncome(data, pengaliMutasi, daftarTrait, pengaliRebirth)
	local jumlahTrait = 0
	for _, trait in ipairs(daftarTrait) do
		jumlahTrait = jumlahTrait + trait.Tambah
	end
	return data.PerDetik * (pengaliMutasi + jumlahTrait) * pengaliRebirth
end

function Economy.formatWaktu(detik)
	local menit = math.floor(detik / 60)
	local sisa = math.floor(detik % 60)
	if menit > 0 then
		return string.format("%d:%02d", menit, sisa)
	end
	return string.format("%d dtk", sisa)
end

return Economy
