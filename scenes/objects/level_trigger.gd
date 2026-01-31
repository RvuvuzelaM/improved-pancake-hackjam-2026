extends Area2D

@export var target_level: String = ""  # np. "1-2"


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.is_in_group("player") and target_level != "":
		if GameData.level_exists(target_level):
			GameData.set_current_level(target_level)
			GameData.unlock_level(target_level)
			SceneManager.change_scene(GameData.get_level_path(target_level))
