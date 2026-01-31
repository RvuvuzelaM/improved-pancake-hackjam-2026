extends CharacterBody2D

signal player_landed
signal mask_changed(new_mask: int)

@onready var animated_sprite = $AnimatedSprite2D2

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
var last_facing_direction := 1.0

enum Mask {NONE, DOUBLE_JUMP, DASH, LEDGE_GRAB}
var equipped_mask := Mask.NONE

# Entry mode state
var _entry_mode: bool = false
const ENTRY_OPACITY: float = 0.6
const ENTRY_DROP_HEIGHT: float = 200.0

# Death state
var _is_dead: bool = false

@export_category("Wall jump variable")
@onready var left_ray: RayCast2D = $Raycasts/LeftRay
@onready var right_ray: RayCast2D = $Raycasts/RightRay
@export var wall_slide_speed = 20.0
@export var wall_x_force = 320.0
@export var wall_y_force = -400.0
@export var is_wall_jumping = false

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
	if _is_dead:
		return

	update_dash_timers(delta)
	apply_gravity(delta)
	handle_jump_input()
	wall_logic()
	handle_horizontal_movement()

	update_animation()

	if _entry_mode and is_on_floor():
		_complete_entry()


func _input(event: InputEvent) -> void:
	if _entry_mode:
		return

	if event.is_action_pressed("switch_mask_none"):
		print("Picked mask: NONE")
		_set_mask(Mask.NONE)
	if event.is_action_pressed("switch_mask_double_jump"):
		print("Picked mask: DOUBLE_JUMP")
		_set_mask(Mask.DOUBLE_JUMP)
	if event.is_action_pressed("switch_mask_dash"):
		print("Picked mask: DASH")
		_set_mask(Mask.DASH)
	if event.is_action_pressed("switch_mask_ledge_grab"):
		print("Picked mask: LEDGE_GRAB")
		_set_mask(Mask.LEDGE_GRAB)
	if event.is_action_pressed("dash"):
		handle_dash_input()


func _set_mask(new_mask: Mask) -> void:
	equipped_mask = new_mask
	emit_signal("mask_changed", new_mask)


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


func update_dash_timers(delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			dash_cooldown_timer = DASH_COOLDOWN


func get_dash_direction(input_direction: float) -> float:
	if input_direction != 0.0:
		return input_direction
	
	if velocity.x != 0.0:
		return sign(velocity.x)
	
	return last_facing_direction


func start_dash() -> void:
	var direction := Input.get_axis("character_left", "character_right")
	if velocity.y == 0 && direction == 0.0:
		return

	dash_direction = get_dash_direction(direction)
	velocity.y = 0.0
	is_dashing = true
	dash_timer = DASH_DURATION

func update_animation() -> void:
	# 2) Pick animation from movement state
	if is_dashing:
		animated_sprite.flip_h = (dash_direction < 0.0)
		animated_sprite.play("dash")
	elif equipped_mask == Mask.LEDGE_GRAB and is_on_wall_only() and not is_on_floor():
		animated_sprite.flip_h = right_ray.is_colliding()
		animated_sprite.play("wall")
	elif not is_on_floor():
		if velocity.x != 0.0:
			animated_sprite.flip_h = (velocity.x < 0.0)
		if velocity.y < 0.0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	else:
		if velocity.x != 0.0:
			animated_sprite.flip_h = (velocity.x < 0.0)
		if abs(velocity.x) > 1.0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")


func handle_horizontal_movement() -> void:
	if _entry_mode:
		velocity.x = 0.0
		move_and_slide()
		return

	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED
	elif is_wall_jumping == false:
		var direction := Input.get_axis("character_left", "character_right")
		if direction != 0.0:
			last_facing_direction = direction
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _get_level() -> Node:
	var levels = get_tree().get_nodes_in_group("level")
	if levels.size() > 0:
		return levels[0]
	return null

func wall_logic():
	if equipped_mask == Mask.LEDGE_GRAB and is_on_wall_only() and not is_on_floor() and velocity.y >= 0:
		velocity.y = wall_slide_speed
		if Input.is_action_just_pressed("character_jump"):
			if left_ray.is_colliding():
				velocity = Vector2(wall_x_force, wall_y_force)
			elif right_ray.is_colliding():
				velocity = Vector2(-wall_x_force, wall_y_force)
			wall_jumping()


func wall_jumping():
	is_wall_jumping = true
	await get_tree().create_timer(0.1).timeout
	is_wall_jumping = false



func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	velocity = Vector2.ZERO
	rotation_degrees = 90

	# Get elapsed time from level and stop timer
	var elapsed_time := 0.0
	var level = _get_level()
	if level:
		level.stop_timer()
		elapsed_time = level.get_elapsed_time()

	_show_death_overlay(elapsed_time)




func _show_death_overlay(elapsed_time: float = 0.0) -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)

	var overlay = ColorRect.new()
	overlay.color = Color(1, 0, 0, 0.3)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(overlay)

	var container = VBoxContainer.new()
	container.set_anchors_preset(Control.PRESET_CENTER)
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	canvas.add_child(container)

	var title = Label.new()
	title.text = "PORAZKA"
	title.add_theme_font_size_override("font_size", 128)
	title.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(title)

	# Show elapsed time
	var time_label = Label.new()
	time_label.text = _format_time(elapsed_time)
	time_label.add_theme_font_size_override("font_size", 64)
	time_label.add_theme_color_override("font_color", Color(1, 1, 1))
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(time_label)

	var hint = Label.new()
	hint.text = "[R] Restart    [ESC] Menu"
	hint.add_theme_font_size_override("font_size", 32)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(hint)


func _format_time(time: float) -> String:
	var minutes := int(time) / 60
	var seconds := int(time) % 60
	var milliseconds := int((time - int(time)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
