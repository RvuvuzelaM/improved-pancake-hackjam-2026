extends CanvasLayer

@onready var double_jump_icon: ColorRect = $Panel/HBox/DoubleJumpIcon
@onready var dash_icon: ColorRect = $Panel/HBox/DashIcon
@onready var ledge_grab_icon: ColorRect = $Panel/HBox/LedgeGrabIcon

const ACTIVE_OPACITY: float = 1.0
const INACTIVE_OPACITY: float = 0.3
const ACTIVE_BRIGHTNESS: float = 1.0
const INACTIVE_BRIGHTNESS: float = 0.5

var player: CharacterBody2D


func _ready() -> void:
	_find_player()
	_update_display()


func _find_player() -> void:
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		player.mask_changed.connect(_on_mask_changed)


func _on_mask_changed(_new_mask: int) -> void:
	_update_display()


func _update_display() -> void:
	if not player:
		return

	var current_mask = player.equipped_mask

	# Reset all to inactive state
	_set_icon_state(double_jump_icon, false)
	_set_icon_state(dash_icon, false)
	_set_icon_state(ledge_grab_icon, false)

	# Highlight the active ability
	match current_mask:
		1:  # DOUBLE_JUMP
			_set_icon_state(double_jump_icon, true)
		2:  # DASH
			_set_icon_state(dash_icon, true)
		3:  # LEDGE_GRAB
			_set_icon_state(ledge_grab_icon, true)


func _set_icon_state(icon: ColorRect, is_active: bool) -> void:
	if is_active:
		icon.modulate.a = ACTIVE_OPACITY
		icon.modulate.r = ACTIVE_BRIGHTNESS
		icon.modulate.g = ACTIVE_BRIGHTNESS
		icon.modulate.b = ACTIVE_BRIGHTNESS
	else:
		icon.modulate.a = INACTIVE_OPACITY
		icon.modulate.r = INACTIVE_BRIGHTNESS
		icon.modulate.g = INACTIVE_BRIGHTNESS
		icon.modulate.b = INACTIVE_BRIGHTNESS
