extends Node
## ID / EN strings — Fase 7.

var locale := "id"
var _strings: Dictionary = {}


func _ready() -> void:
	set_locale(locale)


func set_locale(code: String) -> void:
	locale = code
	var path := "res://data/locale_%s.json" % code
	if not FileAccess.file_exists(path):
		path = "res://data/locale_en.json"
	_strings = {}
	if FileAccess.file_exists(path):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
		if parsed is Dictionary:
			_strings = parsed


func tr_key(key: String, args: Array = []) -> String:
	var s: String = str(_strings.get(key, key))
	for i in args.size():
		s = s.replace("%%%d" % (i + 1), str(args[i]))
		if i == 0 and "%d" in s:
			s = s.replace("%d", str(args[0]))
	return s
