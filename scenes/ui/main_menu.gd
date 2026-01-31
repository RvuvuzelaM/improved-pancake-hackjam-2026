extends Control


func _ready():
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/LevelSelectButton.pressed.connect(_on_level_select_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	_update_play_button()


func _update_play_button():
	$VBoxContainer/PlayButton.text = "PLAY (" + GameData.current_level + ")"


func _on_play_pressed():
	SceneManager.change_scene(GameData.get_current_level_path())


func _on_level_select_pressed():
	SceneManager.change_scene("res://scenes/ui/level_select.tscn")


func _on_quit_pressed():
	get_tree().quit()
