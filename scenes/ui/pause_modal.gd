extends CanvasLayer


func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Control/Panel/VBoxContainer/ResumeButton.pressed.connect(_on_resume)
	$Control/Panel/VBoxContainer/RestartButton.pressed.connect(_on_restart)
	$Control/Panel/VBoxContainer/MenuButton.pressed.connect(_on_menu)
	$Control/Panel/VBoxContainer/ResumeButton.text = "[C] RESUME"
	$Control/Panel/VBoxContainer/RestartButton.text = "[R] RESTART"
	$Control/Panel/VBoxContainer/MenuButton.text = "[M] MENU"


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_on_resume()
		else:
			_show_pause()

	if visible and event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_C:
				_on_resume()
			KEY_R:
				_on_restart()
			KEY_M:
				_on_menu()


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
