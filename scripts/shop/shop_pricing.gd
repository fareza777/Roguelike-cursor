class_name ShopPricing
extends RefCounted
## Dynamic shop prices — floor scaling + rarity.

static func get_buy_price(item: Dictionary, floor_num: int = 1) -> int:
	var base: int = int(item.get("sell_price", 12))
	var rarity_mult := 1.0
	match item.get("rarity", "common"):
		"uncommon": rarity_mult = 1.35
		"rare": rarity_mult = 1.75
		"epic": rarity_mult = 2.4
		"legendary": rarity_mult = 3.2
	var floor_mult := 1.0 + (floor_num - 1) * 0.12
	var affix_mult := 1.25 if item.get("has_affixes", false) else 1.0
	return int(base * 2.0 * rarity_mult * floor_mult * affix_mult)
