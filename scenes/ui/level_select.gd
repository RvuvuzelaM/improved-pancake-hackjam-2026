extends Control


func _ready():
	$VBoxContainer/GridContainer/Level1Button.pressed.connect(_on_level_pressed.bind("1-1"))
	$VBoxContainer/GridContainer/Level2Button.pressed.connect(_on_level_pressed.bind("1-2"))
	$VBoxContainer/GridContainer/Level3Button.pressed.connect(_on_level_pressed.bind("1-3"))
	$VBoxContainer/GridContainer/Level4Button.pressed.connect(_on_level_pressed.bind("1-4"))
	$VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	_update_buttons()


func _update_buttons():
	$VBoxContainer/GridContainer/Level1Button.disabled = not GameData.is_level_unlocked("1-1")
	$VBoxContainer/GridContainer/Level2Button.disabled = not GameData.is_level_unlocked("1-2")
	$VBoxContainer/GridContainer/Level3Button.disabled = not GameData.is_level_unlocked("1-3")
	$VBoxContainer/GridContainer/Level4Button.disabled = not GameData.is_level_unlocked("1-4")


func _on_level_pressed(level_name: String):
	GameData.set_current_level(level_name)
	SceneManager.change_scene("res://scenes/levels/" + level_name + ".tscn")


func _on_back_pressed():
	SceneManager.change_scene("res://scenes/ui/main_menu.tscn")
