extends CharacterBody2D

@export var SPEED := 120.0
@export var BASE_JUMP_VELOCITY := -370.0
@export var DASH_SPEED := 400.0
@export var DASH_DURATION := 0.15
@export var DASH_COOLDOWN := 0.5

var jump_count := 0
var max_jump_count := 2

var is_dashing := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := 0.0

enum Mask {NONE, DOUBLE_JUMP, DASH}
var equipped_mask := Mask.NONE


func _ready():
	add_to_group("player")


func _physics_process(delta: float) -> void:
	update_dash_timers(delta)
	apply_gravity(delta)
	handle_jump_input()
	handle_horizontal_movement()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_mask_none"):
		print("Picked mask: NONE")
		equipped_mask = Mask.NONE
	if event.is_action_pressed("switch_mask_double_jump"):
		print("Picked mask: DOUBLE_JUMP")
		equipped_mask = Mask.DOUBLE_JUMP
	if event.is_action_pressed("switch_mask_dash"):
		print("Picked mask: DASH")
		equipped_mask = Mask.DASH
	if event.is_action_pressed("dash"):
		handle_dash_input()
		
func handle_dash_input() -> void:
	if equipped_mask == Mask.DASH and dash_cooldown_timer <= 0.0:
		start_dash()

func apply_gravity(delta: float) -> void:
	if is_dashing:
		velocity += get_gravity() * delta * 0.1
		return
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

func update_dash_timers(delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			dash_cooldown_timer = DASH_COOLDOWN

func start_dash() -> void:
	var direction := Input.get_axis("character_left", "character_right")
	if direction == 0.0:
		return

	dash_direction = 1.0 if velocity.x >= 0 else -1.0
	velocity.y = 0.0
	is_dashing = true
	dash_timer = DASH_DURATION

func handle_horizontal_movement() -> void:
	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED
	else:
		var direction := Input.get_axis("character_left", "character_right")
		if direction != 0.0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
