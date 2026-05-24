#!/usr/bin/env python3
"""Validate data/items.json and data/enemies.json."""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "data"

RARITIES = {"common", "uncommon", "rare", "epic", "legendary"}
ITEM_TYPES = {"weapon", "armor", "relic", "consumable", "material"}
TIERS = {"normal", "elite", "boss"}
BEHAVIORS = {"chase_melee", "charger", "ranged", "summoner", "boss_phased"}


def load(name):
    path = DATA / name
    if not path.exists():
        print(f"MISSING: {path}")
        sys.exit(1)
    return json.loads(path.read_text(encoding="utf-8"))


def validate_items(data):
    items = data.get("items", [])
    ids = set()
    errors = []
    if len(items) != 100:
        errors.append(f"Expected 100 items, got {len(items)}")
    for it in items:
        iid = it.get("id")
        if not iid or iid in ids:
            errors.append(f"Duplicate or missing id: {iid}")
        ids.add(iid)
        if it.get("rarity") not in RARITIES:
            errors.append(f"{iid}: bad rarity")
        if it.get("type") not in ITEM_TYPES:
            errors.append(f"{iid}: bad type")
        if not it.get("lore"):
            errors.append(f"{iid}: missing lore")
        if not it.get("effects"):
            errors.append(f"{iid}: missing effects")
    return errors


def validate_enemies(data):
    enemies = data.get("enemies", [])
    ids = set()
    errors = []
    if len(enemies) < 20:
        errors.append(f"Expected at least 20 enemies, got {len(enemies)}")
    for en in enemies:
        eid = en.get("id")
        if not eid or eid in ids:
            errors.append(f"Duplicate or missing id: {eid}")
        ids.add(eid)
        if en.get("tier") not in TIERS:
            errors.append(f"{eid}: bad tier")
        if en.get("behavior") not in BEHAVIORS:
            errors.append(f"{eid}: bad behavior")
        if not en.get("lore"):
            errors.append(f"{eid}: missing lore")
        st = en.get("stats", {})
        for k in ("max_hp", "attack", "speed"):
            if k not in st:
                errors.append(f"{eid}: missing stat {k}")
    return errors


def main():
    all_err = []
    all_err += validate_items(load("items.json"))
    all_err += validate_enemies(load("enemies.json"))
    if all_err:
        for e in all_err:
            print("ERROR:", e)
        sys.exit(1)
    enemy_count = len(load("enemies.json").get("enemies", []))
    print(f"OK: 100 items, {enemy_count} enemies validated.")


if __name__ == "__main__":
    main()
