extends CharacterBody2D

const SPEED := 400.0

const BASE_JUMP_VELOCITY := -550.0
const EXTRA_JUMP_FORCE := -700.0   # total additional upward force
const MAX_JUMP_HOLD_TIME := 0.6    # seconds

var jump_hold_time := 0.0
var is_jumping := false

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		# Reset jump state when grounded
		is_jumping = false
		jump_hold_time = 0.0

	# Jump start
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = BASE_JUMP_VELOCITY
		is_jumping = true
		jump_hold_time = 0.0

	# Variable jump height
	if is_jumping and Input.is_action_pressed("ui_accept"):
		if jump_hold_time < MAX_JUMP_HOLD_TIME:
			var t := jump_hold_time / MAX_JUMP_HOLD_TIME
			velocity.y += EXTRA_JUMP_FORCE * delta * (1.0 - t)
			jump_hold_time += delta
	else:
		is_jumping = false

	# Horizontal movement
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
