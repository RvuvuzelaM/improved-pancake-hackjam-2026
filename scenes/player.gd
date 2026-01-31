extends CharacterBody2D

signal player_landed

@export var SPEED := 120.0
@export var BASE_JUMP_VELOCITY := -350.0

var jump_count := 0
var max_jump_count := 2

enum Mask {NONE, DOUBLE_JUMP}
var equipped_mask := Mask.NONE

# Entry mode state
var _entry_mode: bool = false
const ENTRY_OPACITY: float = 0.6
const ENTRY_DROP_HEIGHT: float = 200.0


func _ready():
	add_to_group("player")
	SceneManager.scene_loaded.connect(_on_scene_loaded)


func _on_scene_loaded(level_id: String) -> void:
	if level_id != "":
		_start_entry_mode()


func _start_entry_mode() -> void:
	_entry_mode = true
	modulate.a = ENTRY_OPACITY
	position.y -= ENTRY_DROP_HEIGHT
	velocity.y = 0


func _complete_entry() -> void:
	_entry_mode = false
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	emit_signal("player_landed")


func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump_input()
	handle_horizontal_movement()

	if _entry_mode and is_on_floor():
		_complete_entry()


func _input(event: InputEvent) -> void:
	if _entry_mode:
		return

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
	if _entry_mode:
		return

	if Input.is_action_just_pressed("character_jump"):
		if is_on_floor():
			perform_jump()
		elif jump_count < max_jump_count and equipped_mask == Mask.DOUBLE_JUMP:
			perform_jump()


func perform_jump() -> void:
	velocity.y = BASE_JUMP_VELOCITY
	jump_count += 1


func handle_horizontal_movement() -> void:
	if _entry_mode:
		velocity.x = 0.0
		move_and_slide()
		return

	var direction := Input.get_axis("character_left", "character_right")
	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
