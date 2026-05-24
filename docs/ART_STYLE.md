# Art Direction — Veil of Abyss

## Prinsip: Bukan Pixel Retro

| Hindari | Target |
|---------|--------|
| 16×16 sprite kotak | Siluet jelas, 64–128px character |
| Flat tanpa lighting | **2D lighting** + normal-ish shading via shader |
| Ruangan monoton | Props, variasi lantai, vignette per biome |

## Referensi Mood

- *Hades* — readability, VFX tebal
- *Children of Morta* — painted family tone
- *Revita* — neon organic dungeon

## Palet Fase 0 (Catacombs)

| Role | Hex |
|------|-----|
| Background void | `#0a0a12` |
| Floor stone | `#2a2a3a` |
| Accent magic | `#6b4cff` |
| Danger / enemy | `#c43c3c` |
| Player highlight | `#4ecdc4` |
| Loot rare | `#ffd166` |

## Placeholder Fase 0

- Player/musuh: **Polygon2D + shader glow** (bukan kotak pixel)
- Lantai: TileMap procedural gradient + noise shader
- Partikel: GPUParticles2D pada hit & death

## Pipeline Asset (Fase 4)

1. Concept → Aseprite/Krita (export PNG @2x)
2. Import Godot: Filter **Linear**, Mipmaps off (2D)
3. Atlas per biome di `assets/atlas/`
4. SFX: Audacity → OGG

## Asset Pack Gratis (disarankan ganti sebelum release)

- [Kenney — Abstract Platformer](https://kenney.nl/assets) (UI icons)
- [OpenGameArt — dungeon tiles](https://opengameart.org/) — cek lisensi
- Musik: [Incompetech](https://incompetech.com/) atau komisi

## Shader Wajib

- `shaders/entity_glow.gdshader` — outline + rarity
- `shaders/floor_variation.gdshader` — variasi warna tile
- `shaders/hit_flash.gdshader` — flash putih saat damage

## Play Store Screenshot

Resolusi 1080×1920, tunjukkan: lighting, boss, UI bersih, 3 rarity item di HUD.
