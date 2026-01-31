extends CanvasLayer


func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Control/Panel/VBoxContainer/ResumeButton.pressed.connect(_on_resume)
	$Control/Panel/VBoxContainer/RestartButton.pressed.connect(_on_restart)
	$Control/Panel/VBoxContainer/MenuButton.pressed.connect(_on_menu)


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_on_resume()
		else:
			_show_pause()


func _show_pause():
	visible = true
	get_tree().paused = true


func _on_resume():
	visible = false
	get_tree().paused = false


func _on_restart():
	get_tree().paused = false
	SceneManager.change_scene(GameData.get_current_level_path())


func _on_menu():
	get_tree().paused = false
	SceneManager.change_scene("res://scenes/ui/main_menu.tscn")
