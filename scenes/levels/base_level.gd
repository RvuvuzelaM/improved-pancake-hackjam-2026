extends Node2D
class_name BaseLevel

@export var spawn_position: Vector2 = Vector2.ZERO
@export var trigger_position: Vector2 = Vector2.ZERO
@export var next_level: String = ""

@onready var player: CharacterBody2D = $player
@onready var level_trigger: Area2D = $LevelTrigger


func _ready() -> void:
	_setup_level()


func _setup_level() -> void:
	# Pozycjonuj gracza
	if spawn_position != Vector2.ZERO:
		player.global_position = spawn_position

	# Pozycjonuj i skonfiguruj trigger
	if trigger_position != Vector2.ZERO:
		level_trigger.global_position = trigger_position

	if next_level != "":
		level_trigger.target_level = next_level
