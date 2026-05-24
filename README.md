# Veil of Abyss

Roguelike action **solo-indie** untuk Android (Play Store). Dibangun dengan **Godot 4** — bukan prototype web; fondasi jangka panjang untuk iterasi tanpa batas.

[![Repo](https://img.shields.io/badge/GitHub-fareza777%2FRoguelike--cursor-blue)](https://github.com/fareza777/Roguelike-cursor)

## Tentang Game

Kau adalah **Penjaga Veil** — terjebak di dungeon yang berubah setiap run. Kumpulkan 100+ relik dengan lore dan efek, kalahkan 20+ musuh dengan pola unik, dan selami abyss yang dalam.

| Aspek | Detail |
|-------|--------|
| Genre | Action roguelike, room-based |
| Kamera | Top-down 2D stylized (bukan pixel retro) |
| Run | Permadeath, 15–30 menit per run (target) |
| Konten awal | **100 item** (lore + efek), **20 musuh** |
| Platform | Android → Play Store |

## Quick Start

1. Install [Godot 4.3+](https://godotengine.org/download)
2. Clone repo ini
3. Buka folder di Godot → **Import** `project.godot`
4. Tekan **F5** (scene utama: `scenes/main/Main.tscn`)

### Kontrol (desktop dev)

| Input | Aksi |
|-------|------|
| WASD / Arrow | Gerak |
| Mouse kiri | Serang arah kursor |
| Space | Dodge (i-frames) |
| E | Interaksi / pickup |
| Tab | Inventory (Fase 1) |
| Esc | Pause |

## Struktur Repo

```
├── data/           # items.json (100), enemies.json (20) — sumber kebenaran
├── docs/           # Arsitektur, gaya art, desain item
├── scenes/         # Player, musuh, dungeon, UI
├── scripts/        # Logic: combat, dungeon, data loader
├── assets/         # Shader, audio placeholder, fonts
├── tools/          # Generator & validasi data
└── ROADMAP.md      # Fase 0–7+ detail
```

## Roadmap

Lihat **[ROADMAP.md](ROADMAP.md)** untuk fase pengembangan lengkap (Fase 0 fondasi → Play Store → live ops).

**Fase saat ini:** Fase 0 — vertical slice playable.

## Menambah Item / Musuh

1. Edit `data/items.json` atau `data/enemies.json` (ikuti schema di `docs/DATA_SCHEMA.md`)
2. Jalankan validasi: `python tools/validate_data.py`
3. Restart game — `DataManager` reload otomatis di editor

## Deploy Android (Fase 6)

Godot → Export → Android. Preset awal di `export_presets.cfg`. Butuh JDK 17 + Android SDK.

## Lisensi

Kode: MIT (sesuaikan jika perlu). Asset art placeholder — ganti sebelum release komersial (lihat `docs/ART_STYLE.md`).

## Kontribusi (solo dev)

Repo ini dirancang untuk **satu maintainer jangka panjang**. Issue & milestone di GitHub mengikuti fase di ROADMAP.

---

*“Di bawah Veil, tidak ada yang sama — kecuali kematianmu.”*
