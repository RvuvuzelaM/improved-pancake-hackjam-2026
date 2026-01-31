extends AnimatedSprite2D
class_name DestructableWall

## Ability types that can break this wall
enum BreakAbility {
	DASH,
	TOUCH,
	JUMP_THROUGH
}

## Which abilities can break this wall
@export_flags("Dash", "Touch", "Jump Through") var break_abilities: int = 0

## Time in seconds before respawn (0 = no respawn)
@export var respawn_time: float = 0.0

## Duration of the break animation
@export var break_animation_duration: float = 0.3

## Duration of the fade out effect
@export var fade_duration: float = 0.2

## Delay before breaking starts after requirements are met
@export var break_delay: float = 0.0

var _is_broken: bool = false
var _collision_shape: CollisionShape2D
var _static_body: StaticBody2D

func _ready() -> void:
	# Stop animation and show first frame
	stop()
	frame = 0

	# Cache collision references
	_static_body = $StaticBody2D
	_collision_shape = $StaticBody2D/CollisionShape2D


func can_break_with(ability: BreakAbility) -> bool:
	return break_abilities & (1 << ability) != 0


func try_break(ability: BreakAbility) -> bool:
	if _is_broken:
		return false

	if not can_break_with(ability):
		return false

	_break_wall()
	return true


func _break_wall() -> void:
	_is_broken = true

	if break_delay > 0.0:
		var timer = get_tree().create_timer(break_delay)
		timer.timeout.connect(_start_break_animation)
	else:
		_start_break_animation()


func _start_break_animation() -> void:
	# Disable collision when breaking actually starts
	_collision_shape.set_deferred("disabled", true)

	# Play break animation
	play("default")

	# Fade out during animation and trigger completion
	var anim_duration = sprite_frames.get_frame_count("default") / sprite_frames.get_animation_speed("default")
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, anim_duration)
	tween.tween_callback(_on_break_complete)


func _on_break_complete() -> void:
	# Stop animation and hide
	stop()
	visible = false

	# Schedule respawn if configured
	if respawn_time > 0.0:
		var timer = get_tree().create_timer(respawn_time)
		timer.timeout.connect(_respawn)


func _respawn() -> void:
	# Reset visual state
	stop()
	frame = 0
	modulate.a = 1.0
	visible = true

	# Re-enable collision
	_collision_shape.set_deferred("disabled", false)

	_is_broken = false


## Check if wall is currently broken
func is_broken() -> bool:
	return _is_broken
