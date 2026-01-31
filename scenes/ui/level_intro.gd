extends CanvasLayer

@onready var container: Control = $Container
@onready var background: ColorRect = $Container/Background
@onready var content_box: VBoxContainer = $Container/ContentBox
@onready var accent_bar: ColorRect = $Container/ContentBox/AccentBar
@onready var level_name_label: Label = $Container/ContentBox/LevelName
@onready var level_id_label: Label = $Container/ContentBox/LevelID

const FADE_IN_DURATION: float = 0.4
const FADE_OUT_DURATION: float = 0.5
const BACKGROUND_ALPHA: float = 0.3
const AUTO_HIDE_DELAY: float = 2.5

var _player_ref: CharacterBody2D = null
var _is_fading_out: bool = false


func _ready():
	visible = false
	content_box.modulate.a = 0.0
	background.modulate.a = 0.0

	SceneManager.scene_loaded.connect(_on_scene_loaded)


func _on_scene_loaded(level_id: String) -> void:
	if level_id == "":
		return

	_setup_display(level_id)
	_connect_to_player()
	_animate_in()


func _setup_display(level_id: String) -> void:
	var metadata = GameData.get_level_metadata(level_id)
	var level_color = GameData.get_level_color(level_id)

	level_name_label.text = metadata.get("name", "Unknown")
	level_id_label.text = level_id

	accent_bar.color = level_color
	level_name_label.add_theme_color_override("font_color", level_color)


func _connect_to_player() -> void:
	await get_tree().process_frame

	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player_ref = players[0]
		if _player_ref.has_signal("player_landed") and not _player_ref.player_landed.is_connected(_on_player_landed):
			_player_ref.player_landed.connect(_on_player_landed)


func _on_player_landed() -> void:
	_animate_out()


func _animate_in() -> void:
	visible = true
	_is_fading_out = false

	content_box.position.y = 50

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(content_box, "modulate:a", 1.0, FADE_IN_DURATION)
	tween.tween_property(content_box, "position:y", 0.0, FADE_IN_DURATION)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(background, "modulate:a", BACKGROUND_ALPHA, FADE_IN_DURATION)

	# Auto-hide after delay
	await get_tree().create_timer(AUTO_HIDE_DELAY).timeout
	_animate_out()


func _animate_out() -> void:
	if _is_fading_out or not visible:
		return
	_is_fading_out = true

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(content_box, "modulate:a", 0.0, FADE_OUT_DURATION)
	tween.tween_property(content_box, "position:y", -30.0, FADE_OUT_DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(background, "modulate:a", 0.0, FADE_OUT_DURATION)

	await tween.finished
	visible = false

	if _player_ref and _player_ref.has_signal("player_landed") and _player_ref.player_landed.is_connected(_on_player_landed):
		_player_ref.player_landed.disconnect(_on_player_landed)
	_player_ref = null
