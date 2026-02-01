extends Node2D

const BULLET_SCENE = preload("res://scenes/enemies/bullet.tscn")

@onready var camera_2d: Camera2D = $Camera2D
@onready var boss: Node2D = $Boss

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_2d.enabled = true
	camera_2d.make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	camera_2d.position.y -= 2
	boss.global_position.y -= 2
	print(boss.global_position.y)


func _on_shooting_timer_timeout() -> void:
	var random_x = randf_range(-125.0, 125.0)
	var random_y = randf_range(-10.0, 30.0)
	var spawn_position = boss.global_position + Vector2(random_x, random_y)
	
	var bullet = BULLET_SCENE.instantiate()
	bullet.global_position = spawn_position
	add_child(bullet)
