# CURI BRAINROT: BANJIR MIE AYAM

Entri make.fun `roblox-brainrot-01` — game 3D steal-a-brainrot Indonesia (Luau + Rojo).
Ditulis ulang penuh 18 Nov 2026 di sesi terekam R2 (recording `01a1ece8`).

- **Loop:** beli 12 brainrot orisinal di karpet merah → taruh di base → hasilkan $/detik → beli yang lebih langka → curi dari base lawan / pertahankan basemu → rebirth.
- **12 karakter, 6 rarity:** Common, Rare, Epic, Legendary, Mythic, Secret (Tahu Bulat Terbang sampai Raja Indomie Goreng Abadi). Mutasi Emas/Berlian/Kilat/Pelangi/Hantu + trait bumbu Pedas/Manis/Asin (aditif, rumus `base x (mutasi + trait) x rebirth`).
- **3 ancaman nyata di kode:** maling PvP + 3 bot pencuri (base terkunci 60 dtk +10/rebirth, pikul lambat WalkSpeed 16→9 alias −43,75%, tampar menjatuhkan curian, salip beli 150%), banjir mie tsunami tiap ~50 dtk (sirene + 5 dtk hitung mundur, selamat hanya di base/parit), bos penjaga telur "Bapak Mie Ayam Raksasa" (pecahkan telur → bos mengejar → bawa pulang = menetas Mythic/Secret).
- **Rebirth 5 tingkat:** pengali uang x2–x6 + unlock (lantai 2 base, Speed Coil, Perisai Emas 120 dtk, Teleport Pulang).
- **Fungsi asli yang dipakai (bukan karangan):** `WorldBuilder.bangun`, `CharacterFactory.buatBrainrot`, `BeltSpawner.spawnSatu` / `BeltSpawner.beli`, `WaveSystem.mulai`, `BossEggSystem.pecahkanTelur` / `BossEggSystem.tangkapPemain`, `StealSystem.tampar` / `StealSystem.jatuhkanBawaan`, jadwal rarity di dalam `BeltSpawner.mulai`. RemoteEvent `AksiTelur` terhubung ke `BossEggSystem.pecahkanTelur` (tombol HUD + cek jarak 40 stud dari arena).
- **Perbaikan rewrite ini:** fungsi mati `CharacterData.ambilDariNama` dan `Economy.formatWaktu` dihapus; `AksiTelur` dipakai (bukan dibiarkan nganggur); income + hitungan slot pakai `pairs` (lubang slot bekas curian tidak lagi memotong income); timer Legendary/Mythic independen; bot punya ekonomi sendiri (income + bayar beli, curi slot termahal); klik brainrot di base digabung jadi satu handler; tombol HUD ber-cooldown 0,5 dtk; skala model bos diperbaiki.
- **Struktur:** `src/shared/` (CharacterData, Economy, GameState — satu state server), `src/server/` (WorldBuilder, CharacterFactory, BeltSpawner, BaseManager, StealSystem, WaveSystem, BossEggSystem, RebirthSystem, BotPemain, Remotes, init), `src/client/` (HUD, teks besar di tengah atas, jauh dari pojok kiri atas).
- **Build:** `rojo build default.project.json --output game.rbxl`, lalu `mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts`.
- `screenshots/` berisi 4 gambar komposisi PIL dari dunia/karakter game (BUKAN capture Roblox Studio — lihat laporan produksi-2.md). `PLAY.json` masih placeholder sampai place dipublish Public dari Roblox Studio.
