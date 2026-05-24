# Item Design Guidelines

## 100 Item — Distribusi

| Tipe | Jumlah | Peran |
|------|--------|-------|
| Weapon | 20 | Build damage, on-hit |
| Armor | 15 | Survivability |
| Relic | 20 | Synergy, passive |
| Consumable | 20 | Moment-to-moment |
| Material | 15 | Crafting Fase 2+ |
| Veilbound variant | 10 | Variasi rarity |

## Lore

- Bahasa Indonesia untuk flavor; nama item EN agar universal di store.
- Setiap item punya **satu kebenaran** (secret) — bisa diungkap di codex Fase 2.

## Balance

- Common: +3 stat total
- Legendary: dual effect + stat besar
- Jangan stack lifesteal > 12% tanpa tradeoff (Fase 2)

## Menambah Item #101+

1. Tambah entri di `tools/generate_content.py` atau edit JSON manual
2. `python tools/validate_data.py`
3. Commit dengan tag `content-vX`
