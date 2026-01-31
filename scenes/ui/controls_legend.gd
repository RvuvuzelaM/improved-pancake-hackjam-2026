extends CanvasLayer

# Controls legend - shows key bindings in corner during gameplay
# Can be toggled with H key

var is_visible_legend: bool = true

func _ready() -> void:
	layer = 5
	_update_visibility()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_H:
		is_visible_legend = not is_visible_legend
		_update_visibility()


func _update_visibility() -> void:
	$Panel.visible = is_visible_legend
