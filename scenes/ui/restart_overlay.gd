extends CanvasLayer

const HOLD_TIME: float = 0.8  # Czas trzymania do restartu
const CIRCLE_RADIUS: float = 40.0
const CIRCLE_WIDTH: float = 6.0

var hold_progress: float = 0.0
var is_holding: bool = false

@onready var circle_container: Control = $CircleContainer


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	circle_container.visible = false


func _process(delta):
	if Input.is_action_pressed("restart_level") and not get_tree().paused:
		is_holding = true
		hold_progress += delta / HOLD_TIME
		circle_container.visible = true
		circle_container.queue_redraw()

		if hold_progress >= 1.0:
			_do_restart()
	else:
		if is_holding:
			is_holding = false
			hold_progress = 0.0
			circle_container.visible = false
			circle_container.queue_redraw()


func _do_restart():
	hold_progress = 0.0
	is_holding = false
	circle_container.visible = false
	SceneManager.change_scene(GameData.get_current_level_path())
