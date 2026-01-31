extends Node2D
class_name FadingPlatform

## Time in seconds before respawn (0 = no respawn)
@export var respawn_time: float = 3.0

## Duration of the fade out effect
@export var fade_out_duration: float = 0.5

## Duration of the fade in effect (on respawn)
@export var fade_in_duration: float = 0.3

## Delay before fading starts after player touches
@export var fade_delay: float = 0.5

var _is_faded: bool = false
var _collision_shape: CollisionShape2D
var _static_body: StaticBody2D

func _ready() -> void:
	# Cache collision references
	_static_body = $StaticBody2D
	_collision_shape = $StaticBody2D/CollisionShape2D


func trigger_fade() -> bool:
	if _is_faded:
		return false

	_fade_platform()
	return true


func _fade_platform() -> void:
	_is_faded = true

	if fade_delay > 0.0:
		var timer = get_tree().create_timer(fade_delay)
		timer.timeout.connect(_start_fade_out)
	else:
		_start_fade_out()


func _start_fade_out() -> void:
	# Disable collision when fading starts
	_collision_shape.set_deferred("disabled", true)

	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_out_duration)
	tween.tween_callback(_on_fade_complete)


func _on_fade_complete() -> void:
	visible = false

	# Schedule respawn if configured
	if respawn_time > 0.0:
		var timer = get_tree().create_timer(respawn_time)
		timer.timeout.connect(_respawn)


func _respawn() -> void:
	# Reset visual state
	modulate.a = 0.0
	visible = true

	# Fade in
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_in_duration)
	tween.tween_callback(_on_respawn_complete)


func _on_respawn_complete() -> void:
	# Re-enable collision after fade in completes
	_collision_shape.set_deferred("disabled", false)
	_is_faded = false


## Check if platform is currently faded
func is_faded() -> bool:
	return _is_faded
