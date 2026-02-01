extends Node2D

@onready var camera_2d: Camera2D = $Camera2D
@onready var boss: Node2D = $Boss

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_2d.enabled = true
	camera_2d.make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	camera_2d.position.y -= 1
	boss.global_position.y -= 1
	print(boss.global_position.y)
