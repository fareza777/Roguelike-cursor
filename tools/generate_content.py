#!/usr/bin/env python3
"""Generate items.json (100 items) and enemies.json (20 enemies) for Veil of Abyss."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "data"

RARITIES = ["common", "common", "common", "uncommon", "uncommon", "rare", "epic", "legendary"]
TYPES = ["weapon", "armor", "relic", "consumable", "material"]

WEAPON_NAMES = [
    "Blade of Whispers", "Crimson Fang", "Void Needle", "Sanctum Breaker", "Moonlit Rapier",
    "Ashbringer Stub", "Soul Carver", "Gravepicker", "Echo Katana", "Abyss Cleaver",
    "Penitent Dagger", "Hollow Reaver", "Wraithhook", "Dawn's Lament", "Nightcoil Whip",
    "Thorned Maul", "Glass Shiv", "Emberbrand", "Frostbite Needle", "Stormprong Spear",
]
ARMOR_NAMES = [
    "Veilwalker Mantle", "Catacomb Plate", "Mycelium Vest", "Crystal Aegis", "Shadebound Cloak",
    "Penitent Chain", "Briarheart Mail", "Obsidian Shell", "Luminous Shroud", "Gravewrought Hauberk",
    "Wispwoven Robe", "Ironveil Cuirass", "Ashen Greaves", "Spiritbone Helm", "Abyssal Pauldrons",
]
RELIC_NAMES = [
    "Heart of the Forgotten", "Mirror of False Dawn", "Coin of the Dead", "Lantern of Last Breath",
    "Ring of Endless Steps", "Chalice of Spilled Stars", "Bone Dice of Fate", "Veil Fragment Alpha",
    "Whispering Locket", "Crown of Rusted Thorns", "Hourglass of Stolen Time", "Eye of the Deep",
    "Sigil of Returning Pain", "Ember Core Relic", "Frozen Tear Pendant", "Chain of Bound Souls",
    "Seed of Corruption", "Feather of Weightless Fall", "Anchor of Memory", "Compass of Lost Halls",
]
CONSUMABLE_NAMES = [
    "Vial of Veil Blood", "Greater Healing Draught", "Burst Ember Flask", "Smoke of Retreat",
    "Scroll: Abyss Pulse", "Antidote Spore", "Rage Infusion", "Shielding Tonic", "Soulfood Ration",
    "Bomb: Shrapnel Core", "Elixir of Haste", "Phoenix Ash (Minor)", "Oil of Piercing",
    "Warp Powder", "Golden Sap", "Hex Breaker Tea", "Thundercap Mushroom", "Ghostbrew",
    "Stoneheart Pill", "Lotus of Clarity",
]
MATERIAL_NAMES = [
    "Void Shard", "Catacomb Dust", "Mycelium Fiber", "Crystal Splinter", "Wraith Essence",
    "Blood Amber", "Iron Scrap (Veil)", "Soul Thread", "Corrupted Bone", "Abyss Pearl",
    "Ember Coal", "Frost Scale", "Storm Glass", "Grave Moss", "Penitent Wax",
]

LORE_TEMPLATES = {
    "weapon": [
        "Ditempa di bawah Veil ketika langit masih punya bintang. Pedang ini berbisik nama-nama yang sudah dilupakan.",
        "Setiap tebasan meninggalkan jejak dingin — bukan dari logam, tapi dari kenangan pemilik sebelumnya.",
        "Para Penjaga Veil memakai senjata ini sebagai hukuman: mereka yang gagal, senjata mereka yang menang.",
    ],
    "armor": [
        "Armour ini menyerap ketakutan. Semakin lama kau memakainya, semakin ringan langkah musuh di belakangmu.",
        "Tenunan dari benang jiwa — tidak melindungi tubuh sebanyak melindungi identitas.",
        "Catatan di dalam lapisan dalam: 'Jangan percaya cermin di lantai tiga.'",
    ],
    "relic": [
        "Relik ini tidak memberi kekuatan — ia menukar sesuatu yang tidak kau sadari.",
        "Arkeolog Veil menemukannya terapung di ruangan tanpa pintu. Tidak ada yang meminta untuk mengambilnya.",
        "Bercahaya redup saat ada yang berbohong dalam radius tiga langkah.",
    ],
    "consumable": [
        "Rasanya seperti logam dan madu. Efeknya cepat; penyesalannya lambat.",
        "Dibuat oleh apoteker yang tidak pernah meninggalkan dungeon — resepnya masih berdenyut.",
        "Label sudah pudar. Hanya tersisa peringatan: 'Satu dosis. Satu kesempatan.'",
    ],
    "material": [
        "Bahan ini dipakai crafter Veil untuk mengikat efek pada senjata — atau melepaskannya.",
        "Disimpan dalam kantong timah agar tidak 'bangun' di malam hari.",
        "Pedagang di hub membelinya mahal; mereka tidak tahu dari mana asalnya — dan tidak ingin tahu.",
    ],
}

TAG_POOLS = {
    "weapon": [["melee"], ["melee", "bleed"], ["melee", "fire"], ["ranged"], ["melee", "crit"]],
    "armor": [["defense"], ["defense", "hp"], ["speed"], ["dodge"]],
    "relic": [["passive"], ["on_hit"], ["on_kill"], ["aura"]],
    "consumable": [["heal"], ["buff"], ["damage"], ["utility"]],
    "material": [["craft"]],
}

CONSUMABLE_EFFECTS = [
    {"type": "on_use", "apply": "heal", "value": 35},
    {"type": "on_use", "apply": "buff_haste", "value": 45, "duration": 8},
    {"type": "on_use", "apply": "buff_shield", "value": 10, "duration": 6},
    {"type": "on_use_aoe", "apply": "bomb", "damage": 55, "radius": 110},
    {"type": "on_use_aoe", "apply": "abyss_pulse", "damage": 90, "radius": 140},
]

EFFECT_POOL = [
    {"type": "stat", "stat": "attack", "value": 3},
    {"type": "stat", "stat": "attack", "value": 5},
    {"type": "stat", "stat": "defense", "value": 2},
    {"type": "stat", "stat": "defense", "value": 4},
    {"type": "stat", "stat": "speed", "value": 10},
    {"type": "stat", "stat": "max_hp", "value": 15},
    {"type": "stat", "stat": "max_hp", "value": 25},
    {"type": "on_hit", "proc": 0.12, "apply": "bleed", "damage": 2, "duration": 3},
    {"type": "on_hit", "proc": 0.1, "apply": "burn", "damage": 3, "duration": 2},
    {"type": "on_hit", "proc": 0.08, "apply": "slow", "value": 0.5, "duration": 1.5},
    {"type": "on_kill", "proc": 1.0, "apply": "heal", "value": 5},
    {"type": "passive", "apply": "lifesteal", "value": 0.05},
    {"type": "passive", "apply": "crit_chance", "value": 0.08},
    {"type": "aura", "apply": "burn_aura", "damage": 2, "duration": 999},
]


def pick_rarity(i: int) -> str:
    return RARITIES[i % len(RARITIES)]


def price_for_rarity(r: str) -> int:
    return {"common": 8, "uncommon": 18, "rare": 35, "epic": 60, "legendary": 120}[r]


def gen_items() -> list:
    items = []
    pools = {
        "weapon": WEAPON_NAMES,
        "armor": ARMOR_NAMES,
        "relic": RELIC_NAMES,
        "consumable": CONSUMABLE_NAMES,
        "material": MATERIAL_NAMES,
    }
    idx = 0
    for itype, names in pools.items():
        for j, name in enumerate(names):
            i = idx
            idx += 1
            rarity = pick_rarity(i)
            lore_list = LORE_TEMPLATES[itype]
            lore = lore_list[j % len(lore_list)]
            tags = TAG_POOLS[itype][j % len(TAG_POOLS[itype])]
            e1 = EFFECT_POOL[i % len(EFFECT_POOL)]
            effects = [e1]
            if rarity in ("rare", "epic", "legendary"):
                effects.append(EFFECT_POOL[(i + 7) % len(EFFECT_POOL)])
            stats = {"attack": 0, "defense": 0, "speed": 0, "max_hp": 0}
            if itype == "weapon":
                stats["attack"] = 4 + (i % 12)
            elif itype == "armor":
                stats["defense"] = 2 + (i % 8)
                stats["max_hp"] = (i % 5) * 5
            elif itype == "consumable":
                effects = [CONSUMABLE_EFFECTS[j % len(CONSUMABLE_EFFECTS)]]
            sid = name.lower().replace(" ", "_").replace("(", "").replace(")", "").replace("'", "")[:40]
            items.append({
                "id": f"{itype}_{sid}",
                "name": name,
                "type": itype,
                "rarity": rarity,
                "lore": lore,
                "tags": tags,
                "stats": stats,
                "effects": effects,
                "sell_price": price_for_rarity(rarity),
                "stack_max": 5 if itype == "consumable" else 1,
            })
    # Pad to exactly 100 with variant duplicates themed
    extra_id = 0
    while len(items) < 100:
        base = items[extra_id % len(items)].copy()
        base["id"] = f"{base['id']}_v{extra_id}"
        base["name"] = f"{base['name']} (Veilbound)"
        base["rarity"] = pick_rarity(len(items))
        base["lore"] = base["lore"] + " Variasi Veilbound — energi abyss mengikis tepinya."
        base["sell_price"] = price_for_rarity(base["rarity"]) + 5
        items.append(base)
        extra_id += 1
    return items[:100]


ENEMIES_SPEC = [
    ("slime_void", "Void Slime", "normal", "chase_melee", 28, 4, 0, 70, 35, 1.4,
     "Lump organik yang menetes dari retakan Veil. Ia tidak lapar — ia hanya mendekat."),
    ("bat_carrion", "Carrion Bat", "normal", "ranged", 18, 6, 0, 120, 120, 0.9,
     "Sayapnya sobek, tapi terbang lebih cepat dari yang kau kira. Mengincar leher."),
    ("skeleton_penitent", "Penitent Skeleton", "normal", "chase_melee", 35, 7, 2, 65, 45, 1.1,
     "Tulang berlutut selamanya. Bangkit lagi ketika kau berpaling."),
    ("mushroom_sporeling", "Sporeling", "normal", "ranged", 22, 5, 0, 50, 90, 1.6,
     "Meletuskan awan racun saat mati. Jangan berdiri terlalu dekat."),
    ("ghost_lantern", "Lantern Wraith", "normal", "ranged", 24, 8, 0, 90, 100, 1.3,
     "Cahaya palsu menarikmu ke perangkap. Cahaya asli menyakitkan baginya."),
    ("rat_bonegnaw", "Bonegnaw Rat", "normal", "charger", 20, 5, 0, 140, 30, 0.7,
     "Gerombolan gigi. Satu gigit, sepuluh menyusul dari lubang."),
    ("cultist_veil", "Veil Cultist", "normal", "ranged", 30, 9, 1, 75, 110, 1.5,
     "Bisikkan doa yang tidak kau mengerti. Bolanya bukan api — itu penyesalan."),
    ("golem_shard", "Shard Golem", "normal", "chase_melee", 55, 6, 5, 45, 50, 1.8,
     "Kristal hidup. Retak di dadanya adalah titik lemah — jika kau sempat melihat."),
    ("spider_webbed", "Webbed Stalker", "normal", "charger", 26, 7, 0, 100, 40, 1.0,
     "Menempel di langit-langit ruangan. Turun tanpa suara."),
    ("imp_ember", "Ember Imp", "normal", "ranged", 25, 10, 0, 110, 95, 1.1,
     "Tertawa kecil saat terbakar. Menciptakan lingkaran api di lantai."),
    ("zombie_flooded", "Flooded Dead", "normal", "chase_melee", 48, 8, 1, 55, 42, 1.3,
     "Berat dan basah. Setiap pukulan memercikkan cairan yang menghanguskan."),
    ("archer_bone", "Bone Archer", "normal", "ranged", 22, 11, 0, 60, 180, 2.0,
     "Tidak punya mata tapi tidak pernah meleset pada yang bergerak."),
    ("hound_shadow", "Shadow Hound", "elite", "charger", 40, 12, 2, 160, 38, 0.9,
     "Elite. Menghilang sejenak sebelum menerkam — dengarkan langkahnya, bukan matanya."),
    ("knight_hollow", "Hollow Knight", "elite", "chase_melee", 80, 14, 6, 70, 55, 1.4,
     "Elite. Armor kosong yang masih bergerak dengan disiplin militer."),
    ("witch_fungal", "Fungal Witch", "elite", "summoner", 45, 9, 2, 65, 130, 2.2,
     "Elite. Memanggil Sporeling kecil. Ruangan menjadi taman beracun."),
    ("beast_chimera", "Catacomb Chimera", "elite", "charger", 70, 16, 3, 130, 48, 1.2,
     "Elite. Tiga kepala, satu niat: menghalangi jalan keluar."),
    ("golem_crystal", "Crystal Guardian", "elite", "chase_melee", 100, 12, 8, 40, 60, 2.0,
     "Elite. Memantulkan sebagian damage — serang dari samping."),
    ("reaper_mini", "Veil Reaper", "elite", "ranged", 55, 18, 2, 85, 140, 1.6,
     "Elite. Sabitnya tidak memotong daging — ia memotong waktu di antara detak jantung."),
    ("boss_warden", "Warden of the First Hall", "boss", "boss_phased", 350, 20, 8, 55, 70, 1.0,
     "Boss. Penjaga hall pertama. Dua fase: tombak, lalu badai shard."),
    ("boss_heart", "Heart of the Abyss (Seed)", "boss", "boss_phased", 500, 22, 5, 40, 90, 1.2,
     "Boss. Benih boss sesungguhnya di Fase 3. Untuk Fase 0 — uji mekanik fase."),
]


def gen_enemies() -> list:
    enemies = []
    for row in ENEMIES_SPEC:
        (eid, name, tier, behavior, hp, atk, defn, spd, rng, cd, lore) = row
        loot = "boss_drop" if tier == "boss" else ("elite_drop" if tier == "elite" else "common_tier1")
        enemies.append({
            "id": eid,
            "name": name,
            "tier": tier,
            "lore": lore,
            "stats": {
                "max_hp": hp,
                "attack": atk,
                "defense": defn,
                "speed": spd,
                "attack_range": rng,
                "attack_cooldown": cd,
            },
            "behavior": behavior,
            "loot_table": loot,
            "tags": ["boss"] if tier == "boss" else (["elite"] if tier == "elite" else ["normal"]),
            "xp": 50 if tier == "boss" else (25 if tier == "elite" else 10),
        })
    return enemies


def main():
    DATA.mkdir(parents=True, exist_ok=True)
    items = gen_items()
    enemies = gen_enemies()
    assert len(items) == 100
    assert len(enemies) == 20
    (DATA / "items.json").write_text(
        json.dumps({"data_version": 1, "items": items}, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )
    (DATA / "enemies.json").write_text(
        json.dumps({"data_version": 1, "enemies": enemies}, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )
    print(f"Wrote {len(items)} items and {len(enemies)} enemies to {DATA}")


if __name__ == "__main__":
    main()
