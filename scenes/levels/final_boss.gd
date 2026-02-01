extends Node2D

const BULLET_SCENE = preload("res://scenes/enemies/bullet.tscn")

@onready var camera_2d: Camera2D = $Camera2D
@onready var boss: Node2D = $Boss
@onready var shooting_timer: Timer = $Boss/ShootingTimer

var player: CharacterBody2D = null
var elapsed_time: float = 0.0
var bullets_started: bool = false

const BULLET_START_DELAY: float = 0
const ACCELERATION_DURATION: float = 30.0
const MIN_MOVEMENT_SPEED: float = 2.0
const MAX_MOVEMENT_SPEED: float = 4.0

func _ready() -> void:
	_unlock_all_abilities()
	camera_2d.enabled = true
	camera_2d.make_current()
	_find_player()
	shooting_timer.stop()

func _unlock_all_abilities() -> void:
	var all_abilities = ["d-jump", "dash", "ledge-grab"]
	for ability_id in all_abilities:
		if not GameData.has_ability(ability_id):
			GameData.unlock_ability(ability_id)

func _find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _process(delta: float) -> void:
	elapsed_time += delta
	
	if elapsed_time >= BULLET_START_DELAY and not bullets_started:
		bullets_started = true
		shooting_timer.start()

func _on_timer_timeout() -> void:
	var speed_progress = min(elapsed_time / ACCELERATION_DURATION, 1.0)
	var movement_speed = lerp(MIN_MOVEMENT_SPEED, MAX_MOVEMENT_SPEED, speed_progress)
	
	camera_2d.position.y -= movement_speed
	boss.global_position.y -= movement_speed
	print(boss.global_position.y)

func _on_shooting_timer_timeout() -> void:
	if elapsed_time < BULLET_START_DELAY:
		return

	_spawn_bullet()

func _spawn_bullet() -> void:
	if not player:
		return
	
	var player_pos = player.global_position
	var spawn_x = player_pos.x
	var spawn_y = boss.global_position.y + 30.0
	
	var spawn_position = Vector2(spawn_x, spawn_y)
	var direction = Vector2.UP
	
	var bullet = BULLET_SCENE.instantiate()
	bullet.global_position = spawn_position
	bullet.set_direction(direction)
	add_child(bullet)
