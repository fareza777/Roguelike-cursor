# Arsitektur — Veil of Abyss

## Stack

- **Godot 4.3** (GDScript 2.0)
- **Data:** JSON di `data/` — hot-reload friendly
- **Rendering:** Forward+ mobile, CanvasItem shaders, PointLight2D per ruangan

## Autoload (Singleton)

| Nama | File | Tugas |
|------|------|-------|
| `GameManager` | `scripts/autoload/game_manager.gd` | State run, floor, gold, pause |
| `DataManager` | `scripts/autoload/data_manager.gd` | Load/parse items & enemies |
| `EventBus` | `scripts/autoload/event_bus.gd` | Signal global (damage, kill, pickup) |
| `AudioManager` | `scripts/autoload/audio_manager.gd` | SFX/Music stub Fase 0 |

## Alur Run (target Fase 1+)

```
Main Menu → Run Start → Dungeon Graph
    → Room Load → Combat/Clear → Loot → Next Room
    → Boss → Win/Death → Meta Hub
```

Fase 0: langsung ke **satu ruangan combat** untuk uji sistem.

## Entity Model

```
CharacterBody2D (BaseCharacter)
├── Player
└── BaseEnemy
    ├── enemy_slime.tscn
    └── … (20 scene, data-driven stats)
```

## Combat Pipeline

1. `WeaponController` spawn `HitboxArea` / `Projectile`
2. `Hitbox` → `take_damage(amount, source, tags)`
3. `EffectProcessor.apply(item_effects, event)` pada trigger
4. `EventBus.enemy_killed` → loot roll `LootTable`

## Data-Driven Item

```json
{
  "id": "blade_whisper",
  "effects": [
    { "type": "stat", "stat": "attack", "value": 5 },
    { "type": "on_hit", "proc": 0.15, "apply": "bleed", "duration": 3 }
  ]
}
```

`EffectProcessor` (Fase 2 penuh) membaca tipe; Fase 0 implement subset: `stat`, `on_hit` sederhana.

## Dungeon Room

- `RoomBase` scene: TileMapLayer floor/walls + `RoomProps` + spawn points
- `RoomGenerator` (Fase 1): graph; Fase 0: `rooms/combat_standard.tscn`

## Save (Fase 5)

- `user://save_meta.json` — soul shards, unlocks
- `user://save_run.json` — suspend run (opsional)

## Performance Mobile

- Pooling: `ProjectilePool`, `DamageNumberPool`
- Max enemies per room: 12
- Texture atlas per biome (Fase 4)

## Testing

- `tools/validate_data.py` — schema JSON
- Unit: `tests/unit/` (Godot test scene, Fase 1)
