extends Node

# Aktualny postęp gracza
var current_level: String = "1-1"

# Lista wszystkich poziomów w kolejności
var levels: Array[String] = ["1-1", "1-2", "1-3", "1-4"]

# Odblokowane poziomy
var unlocked_levels: Array[String] = ["1-1"]


func get_current_level_path() -> String:
	return "res://scenes/levels/" + current_level + ".tscn"


func unlock_next_level():
	var idx = levels.find(current_level)
	if idx >= 0 and idx < levels.size() - 1:
		var next = levels[idx + 1]
		if next not in unlocked_levels:
			unlocked_levels.append(next)
		current_level = next


func is_level_unlocked(level_name: String) -> bool:
	return level_name in unlocked_levels


func set_current_level(level_name: String):
	current_level = level_name
