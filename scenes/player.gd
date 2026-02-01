extends CharacterBody2D

signal player_landed
signal mask_changed(new_mask: int)

@onready var animated_sprite = $AnimatedSprite2D2

# Audio players
var _sfx_jump: AudioStreamPlayer
var _sfx_double_jump: AudioStreamPlayer
var _sfx_dash: AudioStreamPlayer
var _sfx_landing: AudioStreamPlayer
var _sfx_wall_jump: AudioStreamPlayer
var _sfx_wall_slide: AudioStreamPlayer
var _sfx_death: AudioStreamPlayer

@export var SPEED := 120.0
@export var BASE_JUMP_VELOCITY := -370.0
@export var DASH_SPEED := 400.0
@export var DASH_DURATION := 0.15
@export var DASH_COOLDOWN := 0.5
@export var COYOTE_TIME_DURATION := 0.15
@export var COYOTE_X_TOLERANCE := 32.0

var jump_count := 0
var max_jump_count := 2
var coyote_time_timer := 0.0
var coyote_x_position := 0.0
var was_on_floor := false

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

# Timer tracking (in player for reliability)
var elapsed_time: float = 0.0
var _timer_running: bool = false
var _timer_ui: CanvasLayer = null
var _timer_label: Label = null

@export_category("Wall jump variable")
@onready var left_ray: RayCast2D = $Raycasts/LeftRay
@onready var right_ray: RayCast2D = $Raycasts/RightRay
@export var wall_slide_speed = 20.0
@export var wall_x_force = 320.0
@export var wall_y_force = -400.0
@export var is_wall_jumping = false
@export var WALL_HOLD_DURATION := 1.5
var wall_hold_timer := 0.0
var _was_wall_sliding := false

func _ready():
	add_to_group("player")
	SceneManager.scene_loaded.connect(_on_scene_loaded)
	was_on_floor = is_on_floor()
	_setup_audio()


func _setup_audio() -> void:
	_sfx_jump = _create_audio_player("res://assets/audio/jump.mp3")
	_sfx_double_jump = _create_audio_player("res://assets/audio/double_jump.mp3")
	_sfx_dash = _create_audio_player("res://assets/audio/dash.mp3")
	_sfx_landing = _create_audio_player("res://assets/audio/landing.mp3")
	_sfx_wall_jump = _create_audio_player("res://assets/audio/wall_jump.mp3")
	_sfx_wall_slide = _create_audio_player("res://assets/audio/wall_slide.mp3")
	_sfx_death = _create_audio_player("res://assets/audio/death.mp3")


func _create_audio_player(path: String) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.stream = load(path)
	add_child(player)
	return player


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
	# Start timer when player lands
	_start_timer()


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	# Update timer
	if _timer_running:
		elapsed_time += delta
		_update_timer_ui()

	update_dash_timers(delta)
	apply_gravity(delta)
	handle_jump_input()
	wall_logic(delta)
	handle_horizontal_movement()

	update_animation()

	if _entry_mode and is_on_floor():
		_complete_entry()
	elif not _entry_mode and not _timer_running and not _is_dead:
		# Fallback: start timer if no entry mode (e.g., direct scene load)
		_start_timer()


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
	update_animation()


func handle_dash_input() -> void:
	if equipped_mask == Mask.DASH and dash_cooldown_timer <= 0.0 and not is_dashing:
		start_dash()


func apply_gravity(delta: float) -> void:
	if is_dashing:
		velocity += get_gravity() * delta * 0.1
		return
	
	if is_on_floor():
		if not was_on_floor and not _entry_mode:
			_sfx_landing.play()
		jump_count = 0
		coyote_time_timer = 0.0
		was_on_floor = true
	else:
		if was_on_floor:
			coyote_x_position = position.x
			coyote_time_timer = COYOTE_TIME_DURATION
		was_on_floor = false
		if coyote_time_timer > 0.0:
			handle_coyote_time(delta)
		velocity += get_gravity() * delta


func handle_coyote_time(delta: float) -> void:
	var horizontal_distance = abs(position.x - coyote_x_position)
	if horizontal_distance <= COYOTE_X_TOLERANCE:
		coyote_time_timer -= delta
	else:
		coyote_time_timer = 0.0

func handle_jump_input() -> void:
	if _entry_mode:
		return

	if Input.is_action_just_pressed("character_jump"):
		if is_on_floor() or coyote_time_timer > 0.0:
			perform_jump()
		elif jump_count < max_jump_count and equipped_mask == Mask.DOUBLE_JUMP:
			perform_jump()


func perform_jump() -> void:
	velocity.y = BASE_JUMP_VELOCITY
	jump_count += 1
	coyote_time_timer = 0.0
	# Play jump or double jump sound
	if jump_count > 1:
		_sfx_double_jump.play()
	else:
		_sfx_jump.play()


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
	_sfx_dash.play()

func _get_mask_color_suffix() -> String:
	match equipped_mask:
		Mask.DOUBLE_JUMP:
			return "_blue"
		Mask.DASH:
			return "_red"
		Mask.LEDGE_GRAB:
			return "_green"
		_:
			return ""


func _get_animation_name(base_name: String) -> String:
	var color_suffix = _get_mask_color_suffix()
	if color_suffix == "":
		return base_name
	return base_name + color_suffix


func update_animation() -> void:
	if is_dashing:
		animated_sprite.flip_h = (dash_direction < 0.0)
		animated_sprite.play(_get_animation_name("dash"))
	elif equipped_mask == Mask.LEDGE_GRAB and is_on_wall_only() and not is_on_floor():
		animated_sprite.flip_h = right_ray.is_colliding()
		animated_sprite.play(_get_animation_name("wall"))
	elif not is_on_floor():
		if velocity.x != 0.0:
			animated_sprite.flip_h = (velocity.x < 0.0)
		if velocity.y < 0.0:
			animated_sprite.play(_get_animation_name("jump"))
		else:
			animated_sprite.play(_get_animation_name("fall"))
	else:
		if velocity.x != 0.0:
			animated_sprite.flip_h = (velocity.x < 0.0)
		if abs(velocity.x) > 1.0:
			animated_sprite.play(_get_animation_name("run"))
		else:
			animated_sprite.play(_get_animation_name("idle"))


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
	_check_destructable_wall_collisions()
	_check_fading_platform_collisions()


func _check_destructable_wall_collisions() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		# Check if we hit a StaticBody2D that's a child of DestructableWall
		if collider is StaticBody2D:
			var parent = collider.get_parent()
			if parent is DestructableWall:
				_try_break_wall(parent)


func _try_break_wall(wall: DestructableWall) -> void:
	# Check dash ability
	if is_dashing:
		wall.try_break(DestructableWall.BreakAbility.DASH)
		return

	# Check touch ability (always active on contact)
	if wall.can_break_with(DestructableWall.BreakAbility.TOUCH):
		wall.try_break(DestructableWall.BreakAbility.TOUCH)
		return

	# Check jump through (when moving upward through the wall)
	if velocity.y < 0 and wall.can_break_with(DestructableWall.BreakAbility.JUMP_THROUGH):
		wall.try_break(DestructableWall.BreakAbility.JUMP_THROUGH)


func _check_fading_platform_collisions() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		# Check if we hit a StaticBody2D that's a child of FadingPlatform
		if collider is StaticBody2D:
			var parent = collider.get_parent()
			if parent is FadingPlatform:
				parent.trigger_fade()

func _start_timer() -> void:
	_timer_running = true
	_create_timer_ui()


func stop_timer() -> void:
	_timer_running = false
	_hide_timer_ui()


func _create_timer_ui() -> void:
	if _timer_ui != null:
		return

	_timer_ui = CanvasLayer.new()
	_timer_ui.layer = 50
	add_child(_timer_ui)

	_timer_label = Label.new()
	_timer_label.text = "00:00.00"
	_timer_label.add_theme_font_size_override("font_size", 32)
	_timer_label.add_theme_color_override("font_color", Color(0, 0, 0))
	_timer_label.add_theme_constant_override("shadow_offset_x", 2)
	_timer_label.add_theme_constant_override("shadow_offset_y", 2)
	_timer_label.position = Vector2(20, 20)
	_timer_ui.add_child(_timer_label)


func _hide_timer_ui() -> void:
	if _timer_ui != null:
		_timer_ui.visible = false


func _update_timer_ui() -> void:
	if _timer_label != null:
		_timer_label.text = _format_time(elapsed_time)


func get_elapsed_time() -> float:
	return elapsed_time

func wall_logic(delta: float):
	var can_hold_wall = equipped_mask == Mask.LEDGE_GRAB and is_on_wall_only() and not is_on_floor() and velocity.y >= 0
	var is_wall_sliding = can_hold_wall and wall_hold_timer < WALL_HOLD_DURATION

	# Handle wall slide sound
	if is_wall_sliding and not _was_wall_sliding:
		_sfx_wall_slide.play()
	elif not is_wall_sliding and _was_wall_sliding:
		_sfx_wall_slide.stop()
	_was_wall_sliding = is_wall_sliding

	if can_hold_wall:
		if wall_hold_timer < WALL_HOLD_DURATION:
			wall_hold_timer += delta
			velocity.y = wall_slide_speed
			if Input.is_action_just_pressed("character_jump"):
				if left_ray.is_colliding():
					velocity = Vector2(wall_x_force, wall_y_force)
				elif right_ray.is_colliding():
					velocity = Vector2(-wall_x_force, wall_y_force)
				_sfx_wall_slide.stop()
				wall_jumping()
		else:
			wall_hold_timer = WALL_HOLD_DURATION
	else:
		wall_hold_timer = 0.0


func wall_jumping():
	is_wall_jumping = true
	_sfx_wall_jump.play()
	await get_tree().create_timer(0.1).timeout
	is_wall_jumping = false



func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	velocity = Vector2.ZERO
	rotation_degrees = 90
	_sfx_death.play()

	# Stop timer and get elapsed time
	stop_timer()
	_show_death_overlay(elapsed_time)




func _show_death_overlay(elapsed_time: float = 0.0) -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)

	var overlay = ColorRect.new()
	overlay.color = Color(1, 0, 0, 0.3)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(overlay)

	# Center container using CenterContainer
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(center)

	var container = VBoxContainer.new()
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(container)

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
