extends Area2D

@export var target_level: String = ""  # np. "1-2"

var _triggered: bool = false


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if _triggered:
		return
	if body.is_in_group("player"):
		_triggered = true
		# Check if this trigger leads to victory (empty target or "victory")
		if target_level == "" or target_level == "victory":
			_show_victory_overlay(body)
		elif GameData.level_exists(target_level):
			_show_completion_overlay(body)


func _show_completion_overlay(player: Node) -> void:
	# Stop player movement
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)

	# Get elapsed time from player
	player.stop_timer()
	var elapsed_time: float = player.get_elapsed_time()

	# Get current level info (the one we're completing)
	var current_level_id = GameData.current_level
	var level_name = GameData.get_level_name(current_level_id)

	# Create overlay
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	get_tree().current_scene.add_child(canvas)

	var overlay = ColorRect.new()
	overlay.color = Color(0, 0.5, 0, 0.3)
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
	title.text = "UKONCZONO"
	title.add_theme_font_size_override("font_size", 96)
	title.add_theme_color_override("font_color", Color(0.2, 1, 0.2))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(title)

	var level_label = Label.new()
	level_label.text = "%s - %s" % [current_level_id, level_name]
	level_label.add_theme_font_size_override("font_size", 48)
	level_label.add_theme_color_override("font_color", Color(0, 0, 0))
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(level_label)

	var time_label = Label.new()
	time_label.text = _format_time(elapsed_time)
	time_label.add_theme_font_size_override("font_size", 64)
	time_label.add_theme_color_override("font_color", Color(1, 1, 1))
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(time_label)

	# Wait 1 second then transition
	await get_tree().create_timer(1.0).timeout

	GameData.set_current_level(target_level)
	GameData.unlock_level(target_level)
	SceneManager.change_scene(GameData.get_level_path(target_level))


func _show_victory_overlay(player: Node) -> void:
	# Stop player movement
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)

	# Get elapsed time from player
	player.stop_timer()
	var elapsed_time: float = player.get_elapsed_time()

	# Create overlay with completely black background
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	get_tree().current_scene.add_child(canvas)

	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 1.0)  # Completely black
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.modulate.a = 0.0  # Start invisible for fade-in
	canvas.add_child(overlay)

	# Fade in the black background
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.5)
	await tween.finished

	# Center container using CenterContainer
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.modulate.a = 0.0  # Start invisible
	canvas.add_child(center)

	var container = VBoxContainer.new()
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(container)

	# Victory title - golden color
	var title = Label.new()
	title.text = "ZWYCIESTWO"
	title.add_theme_font_size_override("font_size", 128)
	title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))  # Gold color
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(title)

	# Show elapsed time
	var time_label = Label.new()
	time_label.text = _format_time(elapsed_time)
	time_label.add_theme_font_size_override("font_size", 64)
	time_label.add_theme_color_override("font_color", Color(1, 1, 1))
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(time_label)

	# Hint to return to menu
	var hint = Label.new()
	hint.text = "[ESC] Menu"
	hint.add_theme_font_size_override("font_size", 32)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(hint)

	# Fade in the text
	var text_tween = create_tween()
	text_tween.tween_property(center, "modulate:a", 1.0, 0.5)


func _format_time(time: float) -> String:
	var minutes := int(time) / 60
	var seconds := int(time) % 60
	var milliseconds := int((time - int(time)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
