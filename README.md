# CURI BRAINROT: BANJIR MIE AYAM

Entri make.fun `roblox-brainrot-01` — game 3D steal-a-brainrot Indonesia (Luau + Rojo).

- **Loop:** beli 12 brainrot orisinal di karpet merah → taruh di base → hasilkan $/detik → beli yang lebih langka → curi dari base lawan / pertahankan basemu → rebirth.
- **12 karakter, 6 rarity:** Common, Rare, Epic, Legendary, Mythic, Secret (Tahu Bulat Terbang sampai Raja Indomie Goreng Abadi). Mutasi Emas/Berlian/Kilat/Pelangi/Hantu + trait bumbu Pedas/Manis/Asin (aditif).
- **3 ancaman nyata di kode:** maling PvP + 3 bot pencuri (base terkunci 60 dtk +10/rebirth, tampar menjatuhkan curian, salip beli 150%), banjir mie tsunami tiap ~50 dtk (sirene + 5 dtk hitung mundur, selamat hanya di base/parit), bos penjaga telur "Bapak Mie Ayam Raksasa" (pecahkan telur → bos mengejar → bawa pulang = menetas).
- **Rebirth 5 tingkat:** pengali uang x2–x6 + unlock (lantai 2 base, Speed Coil, Perisai Emas, Teleport Pulang).
- **Struktur:** `src/shared/` (CharacterData, Economy, GameState — satu state server), `src/server/` (WorldBuilder, CharacterFactory, BeltSpawner, BaseManager, StealSystem, WaveSystem, BossEggSystem, RebirthSystem, BotPemain, Remotes, init), `src/client/` (HUD).
- **Build:** `rojo build default.project.json --output game.rbxl`, lalu `mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts`.
- `screenshots/` berisi 4 gambar kandidat (1-cover = thumbnail). `PLAY.json` masih placeholder sampai place dipublish Public dari Roblox Studio.
