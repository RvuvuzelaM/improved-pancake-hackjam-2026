extends Node2D
class_name BaseLevel

@export var spawn_position: Vector2 = Vector2.ZERO
@export var next_level: String = ""
# trigger_position usunięte - designer ustawia pozycję LevelTrigger ręcznie w edytorze

@onready var player: CharacterBody2D = $player
@onready var level_trigger: Area2D = $LevelTrigger

# Timer tracking
var elapsed_time: float = 0.0
var _timer_running: bool = false


func _ready() -> void:
	add_to_group("level")
	_setup_level()
	# Start timer when player lands
	player.player_landed.connect(_on_player_landed)


func _process(delta: float) -> void:
	if _timer_running:
		elapsed_time += delta


func _on_player_landed() -> void:
	_timer_running = true


func stop_timer() -> void:
	_timer_running = false


func get_elapsed_time() -> float:
	return elapsed_time


func format_time(time: float) -> String:
	var minutes := int(time) / 60
	var seconds := int(time) % 60
	var milliseconds := int((time - int(time)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]


func _setup_level() -> void:
	# Pozycjonuj gracza
	if spawn_position != Vector2.ZERO:
		player.global_position = spawn_position

	# Ustaw target level (pozycja triggera ustawiana ręcznie w edytorze)
	if next_level != "":
		level_trigger.target_level = next_level
