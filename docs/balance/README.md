# Balance Spreadsheet — Fase 2

Referensi cepat untuk tuning. Ubah nilai di CSV lalu sesuaikan kode/data jika perlu.

| File | Isi |
|------|-----|
| `items.csv` | Rarity weights, affix cap, harga dasar |
| `enemies.csv` | Drop chance per tier, gold range |

## Shop pricing formula

`ShopPricing.get_buy_price(item, floor)`:

- Base = `sell_price × 2`
- × rarity multiplier (1.0–3.2)
- × floor multiplier (+12% per floor)
- × 1.25 jika item punya affix

## Synergy

Lihat `data/synergies.json` — minimal 2 tag matching untuk aktif.

## Affix

Lihat `data/affixes.json` — max roll per rarity di `ItemRoller.AFFIX_COUNT_BY_RARITY`.
