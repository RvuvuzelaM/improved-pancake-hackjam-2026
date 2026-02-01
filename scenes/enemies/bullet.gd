extends Node2D

@export var speed: float = 100.0

@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.die()
		queue_free()

func _physics_process(delta: float) -> void:
	global_position.y -= speed * delta
	
	var camera = get_viewport().get_camera_2d()
	if camera:
		var viewport_size = get_viewport().get_visible_rect().size / camera.zoom
		var camera_pos = camera.global_position
		var margin = 100.0
		
		var left_bound = camera_pos.x - viewport_size.x / 2 - margin
		var right_bound = camera_pos.x + viewport_size.x / 2 + margin
		var top_bound = camera_pos.y - viewport_size.y / 2 - margin
		var bottom_bound = camera_pos.y + viewport_size.y / 2 + margin
		
		if global_position.x < left_bound or global_position.x > right_bound or \
		   global_position.y < top_bound or global_position.y > bottom_bound:
			queue_free()

