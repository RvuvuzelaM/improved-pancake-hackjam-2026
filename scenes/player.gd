extends CharacterBody2D

@export var SPEED := 120.0
@export var BASE_JUMP_VELOCITY := -350.0

var jump_count := 0
var max_jump_count := 2

enum Mask {NONE, DOUBLE_JUMP}
var equipped_mask := Mask.NONE

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump_input()
	handle_horizontal_movement()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_mask_none"):
		print("Picked mask: NONE")
		equipped_mask = Mask.NONE
	elif event.is_action_pressed("switch_mask_double_jump"):
		print("Picked mask: DOUBLE_JUMP")
		equipped_mask = Mask.DOUBLE_JUMP

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0

func handle_jump_input() -> void:
	if Input.is_action_just_pressed("character_jump"):
		if is_on_floor():
			perform_jump()
		elif jump_count < max_jump_count and equipped_mask == Mask.DOUBLE_JUMP:
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
