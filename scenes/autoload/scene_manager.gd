extends Node

signal transition_finished
signal scene_loaded(level_id: String)

var transition_layer: CanvasLayer
var color_rect: ColorRect

func _ready():
	transition_layer = CanvasLayer.new()
	transition_layer.layer = 100
	add_child(transition_layer)

	color_rect = ColorRect.new()
	color_rect.color = Color.BLACK
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.modulate.a = 0
	transition_layer.add_child(color_rect)

func change_scene(path: String, duration: float = 0.25):
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	await tween.finished

	get_tree().change_scene_to_file(path)

	# Wait for scene to initialize, then emit scene_loaded
	await get_tree().process_frame
	var level_id = _extract_level_id(path)
	emit_signal("scene_loaded", level_id)

	tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)
	await tween.finished
	emit_signal("transition_finished")


func _extract_level_id(path: String) -> String:
	var filename = path.get_file().get_basename()
	if GameData.level_exists(filename):
		return filename
	return ""
