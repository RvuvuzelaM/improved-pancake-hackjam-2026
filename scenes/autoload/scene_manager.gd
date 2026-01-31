extends Node

signal transition_finished

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

func change_scene(path: String, duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	await tween.finished

	get_tree().change_scene_to_file(path)

	tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)
	await tween.finished
	emit_signal("transition_finished")
