extends Node

# Aktualny postęp gracza
var current_level: String = "1-1"

# Słownik poziomów: ID -> ścieżka do sceny
var levels: Dictionary = {
	"1-1": "res://scenes/levels/1-1.tscn",
	"1-2": "res://scenes/levels/1-2.tscn",
	"1-3": "res://scenes/levels/1-3.tscn",
	"1-4": "res://scenes/levels/1-4.tscn",
}

# Kolejność poziomów (do level select)
var level_order: Array[String] = ["1-1", "1-2", "1-3", "1-4"]

# Odblokowane poziomy
var unlocked_levels: Array[String] = ["1-1"]


func get_current_level_path() -> String:
	return get_level_path(current_level)


func get_level_path(level_id: String) -> String:
	return levels.get(level_id, "")


func level_exists(level_id: String) -> bool:
	return levels.has(level_id)


func unlock_level(level_id: String):
	if level_id not in unlocked_levels and level_exists(level_id):
		unlocked_levels.append(level_id)


func unlock_next_level():
	var idx = level_order.find(current_level)
	if idx >= 0 and idx < level_order.size() - 1:
		var next = level_order[idx + 1]
		unlock_level(next)
		current_level = next


func is_level_unlocked(level_id: String) -> bool:
	return level_id in unlocked_levels


func set_current_level(level_id: String):
	if level_exists(level_id):
		current_level = level_id
