class_name DungeonGenerator
extends RefCounted
## Generates linear floor plans with room type variety.

enum RoomType { START, COMBAT, ELITE, SHOP, REST, BOSS, EXIT }

const FLOOR_COUNT := 3

static func generate_run() -> Array:
	var floors: Array = []
	for f in range(1, FLOOR_COUNT + 1):
		floors.append(generate_floor(f))
	return floors


static func generate_floor(floor_num: int) -> Array:
	var rooms: Array = []
	rooms.append(_room(RoomType.START, floor_num))
	match floor_num:
		1:
			rooms.append(_room(RoomType.COMBAT, floor_num, 4))
			rooms.append(_room(RoomType.COMBAT, floor_num, 4))
			rooms.append(_room(RoomType.SHOP, floor_num))
			rooms.append(_room(RoomType.COMBAT, floor_num, 5))
			rooms.append(_room(RoomType.REST, floor_num))
			rooms.append(_room(RoomType.EXIT, floor_num))
		2:
			rooms.append(_room(RoomType.COMBAT, floor_num, 5))
			rooms.append(_room(RoomType.ELITE, floor_num, 1))
			rooms.append(_room(RoomType.REST, floor_num))
			rooms.append(_room(RoomType.COMBAT, floor_num, 5))
			rooms.append(_room(RoomType.SHOP, floor_num))
			rooms.append(_room(RoomType.ELITE, floor_num, 2))
			rooms.append(_room(RoomType.EXIT, floor_num))
		3:
			rooms.append(_room(RoomType.COMBAT, floor_num, 5))
			rooms.append(_room(RoomType.ELITE, floor_num, 2))
			rooms.append(_room(RoomType.SHOP, floor_num))
			rooms.append(_room(RoomType.REST, floor_num))
			rooms.append(_room(RoomType.COMBAT, floor_num, 6))
			rooms.append(_room(RoomType.BOSS, floor_num))
		_:
			rooms.append(_room(RoomType.COMBAT, floor_num, 4))
			rooms.append(_room(RoomType.EXIT, floor_num))
	return rooms


static func _room(type: RoomType, floor_num: int, spawn_count: int = 0) -> Dictionary:
	var type_name := RoomType.keys()[type]
	var cfg := {
		"type": type_name.to_lower(),
		"floor": floor_num,
		"spawn_count": spawn_count,
		"enemy_ids": _enemy_pool(type, floor_num),
		"label": _label_for(type, floor_num),
	}
	if type == RoomType.BOSS:
		cfg["boss_id"] = "boss_warden" if floor_num < 3 else "boss_heart"
		cfg["spawn_count"] = 1
	return cfg


static func _label_for(type: RoomType, floor_num: int) -> String:
	match type:
		RoomType.START: return "Entrance"
		RoomType.COMBAT: return "Combat Hall"
		RoomType.ELITE: return "Elite Chamber"
		RoomType.SHOP: return "Veil Merchant"
		RoomType.REST: return "Sanctum Rest"
		RoomType.BOSS: return "Boss — Floor %d" % floor_num
		RoomType.EXIT: return "Stair Down"
	return "Unknown"


static func _enemy_pool(type: RoomType, floor_num: int) -> Array[String]:
	var normal: Array[String] = [
		"slime_void", "bat_carrion", "skeleton_penitent", "rat_bonegnaw",
		"imp_ember", "zombie_flooded", "mushroom_sporeling"
	]
	var elite: Array[String] = [
		"hound_shadow", "knight_hollow", "witch_fungal", "beast_chimera", "reaper_mini"
	]
	match type:
		RoomType.ELITE:
			return elite
		RoomType.COMBAT:
			if floor_num >= 2:
				return [
					"slime_void", "bat_carrion", "skeleton_penitent", "rat_bonegnaw",
					"imp_ember", "cultist_veil", "spider_webbed", "archer_bone"
				]
			return normal
		_:
			return normal
