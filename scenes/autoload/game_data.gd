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

# Metadane poziomów: ID -> {name, color}
var level_metadata: Dictionary = {
	"1-1": {"name": "First Steps", "color": "#4CAF50"},
	"1-2": {"name": "Rising Tide", "color": "#2196F3"},
	"1-3": {"name": "Shadow Dance", "color": "#9C27B0"},
	"1-4": {"name": "Final Leap", "color": "#FF5722"},
}

# Odblokowane poziomy
var unlocked_levels: Array[String] = ["1-1"]

# Unlocked abilities - starts empty, player collects them during gameplay
# Valid abilities: "d-jump", "dash", "ledge-grab"
var unlocked_abilities: Array[String] = []

signal ability_unlocked(ability_id: String)


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


func get_level_metadata(level_id: String) -> Dictionary:
	return level_metadata.get(level_id, {"name": "Unknown", "color": "#FFFFFF"})


func get_level_name(level_id: String) -> String:
	return get_level_metadata(level_id).get("name", "Unknown")


func get_level_color(level_id: String) -> Color:
	var hex = get_level_metadata(level_id).get("color", "#FFFFFF")
	return Color.html(hex)


# Ability management functions
func has_ability(ability_id: String) -> bool:
	return ability_id in unlocked_abilities


func unlock_ability(ability_id: String) -> void:
	if ability_id not in unlocked_abilities:
		unlocked_abilities.append(ability_id)
		ability_unlocked.emit(ability_id)


func get_unlocked_abilities() -> Array[String]:
	return unlocked_abilities
