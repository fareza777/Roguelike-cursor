# Veil of Abyss — Roadmap Pengembangan Jangka Panjang

> **Visi:** Roguelike action solo-indie berkualitas Play Store. Bukan prototype HTML — fondasi Godot 4, data-driven, iterasi selamanya.

**Engine:** Godot 4.3+ · **Platform target:** Android (Play Store) → iOS (opsional)  
**Gaya visual:** Stylized 2D painted / neon-dungeon (bukan pixel 8×8) — lighting, partikel, shader.

---

## Fase 0 — Fondasi & Vertical Slice (Minggu 1–4) ✅ *sedang dibangun*

| Deliverable | Status |
|-------------|--------|
| Struktur repo, `project.godot`, autoload | ✅ |
| Schema data: 100 item + 20 musuh (lore + efek) | ✅ |
| Player movement + dodge + health | ✅ |
| 1 ruangan combat + spawn musuh | ✅ |
| Combat dasar (melee + projectile hook) | ✅ |
| HUD minimal (HP, floor, gold) | ✅ |
| Dokumen arsitektur & art pipeline | ✅ |

**Exit criteria:** Bisa main 1 run: masuk ruangan → bunuh musuh → loot item → mati/restart.

---

## Fase 1 — Core Loop Roguelike (Minggu 5–10)

- [ ] **Dungeon generator:** graph ruangan (start → combat → shop → boss → exit)
- [ ] **5 tipe ruangan:** combat, elite, shop, rest, boss (layout tile + props)
- [ ] **Floor progression:** 3 lantai demo → skala ke 6+ lantai
- [ ] **Permadeath run** + statistik run di layar game over
- [ ] **Inventory 6 slot** + equip weapon/armor/relic
- [ ] **Pickup & drop** dari musuh (weighted loot table per musuh)
- [ ] **Save run** (suspend) — opsional Fase 1 akhir

**Exit criteria:** Run lengkap 15–25 menit, 3 floor, boss floor 3.

---

## Fase 2 — Kedalaman Item & Sinergi (Minggu 11–18)

- [ ] Parser efek lengkap: `on_hit`, `on_kill`, `passive`, `aura`, `proc`
- [ ] **Rarity & affix** roll pada drop
- [ ] **Synergy tags** (fire, bleed, crit, summon…) — UI indicator
- [ ] **Consumable** (potion, bomb, scroll)
- [ ] **Shop NPC** + harga dinamis
- [ ] **Codex** in-game (100 entri lore terbuka progresif)
- [ ] Balance pass v1 (spreadsheet `docs/balance/`)

**Exit criteria:** Minimal 30 build berbeda terasa unik; codex 100% terbaca.

---

## Fase 3 — Musuh & AI (Minggu 19–26)

- [ ] Implementasi penuh **20 musuh** (behavior tree / state machine)
- [ ] Elite variant (+ affix: fast, tank, splitter…)
- [ ] **3 boss** dengan fase mekanik
- [ ] Telegraph serangan (area warning shader)
- [ ] Spawn wave & room modifier (darkness, poison fog…)

**Exit criteria:** Semua 20 musuh punya pola unik; 1 boss di floor 3.

---

## Fase 4 — Grafis & Juice (Minggu 27–36)

- [ ] Ganti placeholder → **sprite hand-painted** atau asset pack berlisensi
- [ ] **Tileset ruangan** per biome (Catacombs, Fungal, Crystal)
- [ ] Animasi player 8-arah + hit flash
- [ ] **Screen shake, hitstop, damage numbers**
- [ ] Musik adaptive per biome + SFX layer
- [ ] **Lighting 2D** per ruangan (torch, crystal glow)
- [ ] Shader: dissolve death, rarity glow pickup

**Exit criteria:** Trailer 30 detik terlihat “store-ready”.

---

## Fase 5 — Meta Progression (Minggu 37–44)

- [ ] **Hub** antara run (Veil Sanctum)
- [ ] Mata uarga meta: **Soul Shards** → unlock skill tree
- [ ] 12 upgrade permanen (HP, speed, starting weapon…)
- [ ] Daily challenge seed
- [ ] Achievement lokal → Play Games (Fase 6)

**Exit criteria:** Alasan main ulang 20+ jam; meta tidak pay-to-win.

---

## Fase 6 — Android & Play Store (Minggu 45–52)

- [ ] Export preset Android (AAB)
- [ ] Touch virtual joystick + tombol dodge/skill
- [ ] Safe area, resolusi 16:9–20:9
- [ ] Optimasi: object pooling, texture atlas
- [ ] **Google Play Games** login, leaderboard
- [ ] Privacy policy, rating konten, store listing ID/EN
- [ ] Closed testing → Open testing → Production

**Exit criteria:** Game live di Play Store v0.1.0.

---

## Fase 7+ — Live Ops (Bulan 4+)

| Iterasi | Isi |
|---------|-----|
| v0.2 | +20 item, 5 musuh, biome baru |
| v0.3 | Co-op async ghost (opsional) |
| v0.4 | Seasonal modifier |
| v0.5 | Bahasa lengkap EN + ID |
| v1.0 | 150 item, 35 musuh, 5 boss, endless mode |

---

## Prinsip Maintainability (solo dev)

1. **Semua konten di JSON** — tambah item tanpa ubah scene.
2. **Satu musuh = satu scene** + script extends `BaseEnemy`.
3. **Tag-driven synergy** — desain di spreadsheet, bukan hardcode.
4. **Semantic versioning** data (`data_version` di save).
5. **CI ringan:** validasi JSON + Godot headless test (Fase 6).

---

## Metrik Sukses per Fase

| Fase | Metrik |
|------|--------|
| 0 | 5 menit fun, 0 crash |
| 1 | Retention sesi 2: 40%+ |
| 2 | ≥3 synergy “wow” per run |
| 3 | Death fairness survey (diri sendiri): 70% salah player |
| 4 | Store screenshot siap |
| 5 | D7 retention target 15% (indie realistis) |
| 6 | Rating ≥4.0 pertama 100 review |

---

*Terakhir diperbarui: Fase 0 — fondasi repo.*
