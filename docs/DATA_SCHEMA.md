# Data Schema

## items.json

```json
{
  "data_version": 1,
  "items": [
    {
      "id": "string_unique",
      "name": "Display Name",
      "type": "weapon|armor|relic|consumable|material",
      "rarity": "common|uncommon|rare|epic|legendary",
      "lore": "Flavor text 1-3 kalimat.",
      "tags": ["fire", "melee"],
      "stats": { "attack": 0, "defense": 0, "speed": 0, "max_hp": 0 },
      "effects": [
        { "type": "stat", "stat": "attack", "value": 3 },
        { "type": "on_hit", "proc": 0.1, "apply": "burn", "damage": 2, "duration": 2 }
      ],
      "sell_price": 10,
      "stack_max": 1
    }
  ]
}
```

### Effect types (implementasi bertahap)

| type | Fase | Deskripsi |
|------|------|-----------|
| `stat` | 0 | Modifier flat |
| `on_hit` | 0–2 | Proc saat pemain mengenai musuh |
| `on_kill` | 2 | Saat kill |
| `passive` | 2 | Selalu aktif |
| `on_damaged` | 3 | Saat terkena hit |
| `aura` | 3 | Radius ke musuh |

## enemies.json

```json
{
  "data_version": 1,
  "enemies": [
    {
      "id": "slime_void",
      "name": "Void Slime",
      "tier": "normal|elite|boss",
      "lore": "...",
      "stats": {
        "max_hp": 30,
        "attack": 5,
        "defense": 0,
        "speed": 80,
        "attack_range": 40,
        "attack_cooldown": 1.2
      },
      "behavior": "chase_melee|charger|ranged|summoner|boss_phased",
      "loot_table": "common_tier1",
      "tags": ["organic", "slow"],
      "xp": 10
    }
  ]
}
```

## loot_tables.json (Fase 1)

Weighted drop per `loot_table` id.
