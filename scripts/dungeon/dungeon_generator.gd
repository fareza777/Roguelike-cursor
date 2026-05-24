class_name DungeonGenerator
extends RefCounted

enum RoomType { START, COMBAT, ELITE, SHOP, REST, BOSS, EXIT }

const FLOOR_COUNT := 3


static func generate_run() -> Array:
	var floors: Array = []
	for f in range(1, FLOOR_COUNT + 1):
		floors.append(generate_floor(f))
	return floors


static func generate_endless() -> Array:
	var floors := generate_run()
	for f in range(4, 7):
		floors.append(generate_floor(f))
	return floors


static func generate_floor(floor_num: int) -> Array:
	var rooms: Array = []
	var biome: String = ["catacombs", "fungal", "crystal"][mini(floor_num - 1, 2)]
	rooms.append(_room(RoomType.START, floor_num, 0, biome))
	match floor_num:
		1:
			rooms.append(_room(RoomType.COMBAT, floor_num, 4, biome))
			rooms.append(_room(RoomType.COMBAT, floor_num, 4, biome))
			rooms.append(_room(RoomType.SHOP, floor_num, 0, biome))
			rooms.append(_room(RoomType.COMBAT, floor_num, 5, biome))
			rooms.append(_room(RoomType.REST, floor_num, 0, biome))
			rooms.append(_room(RoomType.EXIT, floor_num, 0, biome))
		2:
			rooms.append(_room(RoomType.COMBAT, floor_num, 5, biome))
			rooms.append(_room(RoomType.ELITE, floor_num, 1, biome))
			rooms.append(_room(RoomType.REST, floor_num, 0, biome))
			rooms.append(_room(RoomType.COMBAT, floor_num, 5, biome))
			rooms.append(_room(RoomType.SHOP, floor_num, 0, biome))
			rooms.append(_room(RoomType.BOSS, floor_num, 0, biome, "boss_warden"))
			rooms.append(_room(RoomType.EXIT, floor_num, 0, biome))
		3:
			rooms.append(_room(RoomType.COMBAT, floor_num, 5, biome))
			rooms.append(_room(RoomType.ELITE, floor_num, 2, biome))
			rooms.append(_room(RoomType.SHOP, floor_num, 0, biome))
			rooms.append(_room(RoomType.REST, floor_num, 0, biome))
			rooms.append(_room(RoomType.BOSS, floor_num, 0, biome, "boss_veil_serpent"))
			rooms.append(_room(RoomType.BOSS, floor_num, 0, biome, "boss_heart"))
		_:
			rooms.append(_room(RoomType.COMBAT, floor_num, 4 + floor_num, biome))
			if floor_num % 2 == 0:
				rooms.append(_room(RoomType.BOSS, floor_num, 0, biome, "boss_warden"))
			rooms.append(_room(RoomType.EXIT, floor_num, 0, biome))
	return rooms


static func _room(type: RoomType, floor_num: int, spawn_count: int = 0, biome: String = "catacombs", boss_id: String = "") -> Dictionary:
	var type_name := RoomType.keys()[type]
	var cfg := {
		"type": type_name.to_lower(),
		"floor": floor_num,
		"spawn_count": spawn_count,
		"enemy_ids": _enemy_pool(type, floor_num),
		"label": _label_for(type, floor_num, boss_id),
		"biome": biome,
		"modifier": DataManager.roll_room_modifier(),
	}
	if type == RoomType.BOSS:
		cfg["boss_id"] = boss_id if not boss_id.is_empty() else "boss_warden"
		cfg["spawn_count"] = 1
	return cfg


static func _label_for(type: RoomType, floor_num: int, boss_id: String) -> String:
	match type:
		RoomType.START: return "Entrance"
		RoomType.COMBAT: return "Combat Hall"
		RoomType.ELITE: return "Elite Chamber"
		RoomType.SHOP: return "Veil Merchant"
		RoomType.REST: return "Sanctum Rest"
		RoomType.BOSS:
			if boss_id == "boss_veil_serpent":
				return "Boss — Veil Serpent"
			if boss_id == "boss_heart":
				return "Boss — Heart of Abyss"
			return "Boss — Warden"
		RoomType.EXIT: return "Stair Down"
	return "Unknown"


static func _enemy_pool(type: RoomType, floor_num: int) -> Array[String]:
	var normal: Array[String] = [
		"slime_void", "bat_carrion", "skeleton_penitent", "rat_bonegnaw",
		"imp_ember", "zombie_flooded", "mushroom_sporeling"
	]
	var elite: Array[String] = [
		"hound_shadow", "knight_hollow", "witch_fungal", "beast_chimera", "reaper_mini", "golem_crystal"
	]
	match type:
		RoomType.ELITE:
			return elite
		RoomType.COMBAT:
			if floor_num >= 2:
				return [
					"slime_void", "bat_carrion", "skeleton_penitent", "rat_bonegnaw",
					"imp_ember", "cultist_veil", "spider_webbed", "archer_bone", "ghost_lantern"
				]
			return normal
		_:
			return normal
