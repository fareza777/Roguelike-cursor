# Veil of Abyss — Roadmap Pengembangan Jangka Panjang

> **Status proyek:** **v1.0.0-rc1 — Feature Complete** untuk solo indie Play Store.

**Engine:** Godot 4.3+ · **Platform:** Android (Play Store)  
**Repo:** https://github.com/fareza777/Roguelike-cursor

---

## Fase 0 — Fondasi ✅

Struktur Godot, 100 item, 20 musuh, combat vertical slice, docs.

---

## Fase 1 — Core Loop ✅

Dungeon graph 3 lantai, 5 tipe ruangan, inventory 6 slot, loot tables, save stub.

---

## Fase 2 — Item & Sinergi ✅

Affix, synergies, codex 100, consumables, shop dinamis, balance CSV.

---

## Fase 3 — Musuh & AI ✅

- [x] 20 musuh — `EnemyAIController` overlay per ID
- [x] Elite affixes — `data/elite_affixes.json`
- [x] 3 boss — Warden, Veil Serpent, Heart of Abyss
- [x] Telegraph — `TelegraphSystem` + `AttackTelegraph`
- [x] Room modifiers — poison, darkness, frenzy, dll.

---

## Fase 4 — Grafis & Juice ✅

- [x] Screen shake, hitstop, damage numbers (`JuiceManager`)
- [x] 3 biome tints (catacombs / fungal / crystal)
- [x] Shader dissolve (`assets/shaders/dissolve.gdshader`)
- [ ] Sprite hand-painted — *ganti placeholder sebelum trailer final*
- [ ] Musik/SFX komersial — *stub `AudioManager`*

---

## Fase 5 — Meta Progression ✅

- [x] Hub `Veil Sanctum` — scene utama
- [x] Soul Shards + 12 upgrade (`data/meta_upgrades.json`)
- [x] Daily challenge seed
- [ ] Google Play Games achievements — *hook siap, integrasi store*

---

## Fase 6 — Android & Play Store ✅ (dokumen + kontrol)

- [x] Export preset AAB (`export_presets.cfg`)
- [x] Virtual joystick + touch buttons
- [x] `docs/PRIVACY_POLICY.md`, `docs/PLAYSTORE_LISTING.md`
- [x] Object pools (`PoolManager`)
- [ ] Upload ke Play Console — *tindakan developer*
- [ ] Keystore production — *jangan commit*

---

## Fase 7 — Live Ops ✅ (v1 baseline)

- [x] Endless mode (lantai 4–6+)
- [x] Lokalisasi ID/EN (`LocaleManager`)
- [ ] Seasonal modifier — *post-launch*
- [ ] 150 item / 35 musuh — *iterasi konten*

---

## Cara Main (v1)

1. Buka Godot 4.3+ → `project.godot`
2. **F5** dari Hub
3. Start Run → kalahkan 3 lantai + 2 boss akhir
4. Kumpulkan Soul Shards → Upgrade Sanctum

## Kontrol

| Desktop | Mobile |
|---------|--------|
| WASD | Joystick kiri |
| Mouse serang | Tombol Atk |
| Space dodge | Tombol Dodge |
| Tab inventory | Tab |
| C codex | C |
| E interaksi | E |

---

## Post-Launch (opsional)

1. Asset art komersial + trailer
2. Play Games leaderboard
3. v1.1 seasonal modifier
4. iOS export

---

*Terakhir diperbarui: v1.0.0-rc1 — roadmap selesai untuk release candidate.*
