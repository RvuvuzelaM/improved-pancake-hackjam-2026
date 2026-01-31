extends CharacterBody2D

@export var SPEED := 300.0
@export var BASE_JUMP_VELOCITY := -500.0

var jump_count := 0
var max_jump_count := 2

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump_input()
	handle_horizontal_movement()


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0

func handle_jump_input() -> void:
	if Input.is_action_just_pressed("character_jump"):
		if is_on_floor():
			perform_jump()
		elif jump_count < max_jump_count:
			perform_jump()

func perform_jump() -> void:
	velocity.y = BASE_JUMP_VELOCITY
	jump_count += 1

func handle_horizontal_movement() -> void:
	var direction := Input.get_axis("character_left", "character_right")
	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
