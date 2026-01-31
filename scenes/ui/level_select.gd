extends Control


func _ready():
	$VBoxContainer/GridContainer/Level1Button.pressed.connect(_on_level_pressed.bind("1-1"))
	$VBoxContainer/GridContainer/Level2Button.pressed.connect(_on_level_pressed.bind("1-2"))
	$VBoxContainer/GridContainer/Level3Button.pressed.connect(_on_level_pressed.bind("1-3"))
	$VBoxContainer/GridContainer/Level4Button.pressed.connect(_on_level_pressed.bind("1-4"))
	$VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	$VBoxContainer/GridContainer/Level1Button.text = "[1] 1-1"
	$VBoxContainer/GridContainer/Level2Button.text = "[2] 1-2"
	$VBoxContainer/GridContainer/Level3Button.text = "[3] 1-3"
	$VBoxContainer/GridContainer/Level4Button.text = "[4] 1-4"
	$VBoxContainer/BackButton.text = "[B] BACK"
	_update_buttons()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				if GameData.is_level_unlocked("1-1"):
					_on_level_pressed("1-1")
			KEY_2:
				if GameData.is_level_unlocked("1-2"):
					_on_level_pressed("1-2")
			KEY_3:
				if GameData.is_level_unlocked("1-3"):
					_on_level_pressed("1-3")
			KEY_4:
				if GameData.is_level_unlocked("1-4"):
					_on_level_pressed("1-4")
			KEY_B:
				_on_back_pressed()


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
