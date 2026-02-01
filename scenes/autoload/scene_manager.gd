extends Node

signal transition_finished
signal scene_loaded(level_id: String)

var transition_layer: CanvasLayer
var color_rect: ColorRect

# Music system
var _music_player: AudioStreamPlayer
var _current_music: String = ""
const MUSIC_FADE_DURATION: float = 0.5
const MUSIC_VOLUME_DB: float = -10.0

# Level to music mapping
var _level_music: Dictionary = {
	"1-1": "res://assets/music/forest_calm.mp3",
	"1-2": "res://assets/music/adventure.mp3",
	"final_boss": "res://assets/music/boss.mp3",
}

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

	_music_player = AudioStreamPlayer.new()
	_music_player.volume_db = MUSIC_VOLUME_DB
	add_child(_music_player)
	
	if get_tree().has_signal("current_scene_changed"):
		get_tree().current_scene_changed.connect(_on_scene_changed)
	
	call_deferred("_check_current_scene_music")

func _on_scene_changed():
	call_deferred("_check_current_scene_music")

func _check_current_scene_music():
	await get_tree().process_frame
	await get_tree().process_frame
	var current_scene = get_tree().current_scene
	if current_scene == null:
		return
	
	var scene_path = current_scene.scene_file_path
	if scene_path == "":
		return
	
	var level_id = _extract_level_id(scene_path)
	if level_id != "":
		_play_level_music(level_id)

func change_scene(path: String, duration: float = 0.25):
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	await tween.finished

	get_tree().change_scene_to_file(path)

	await get_tree().process_frame
	var level_id = _extract_level_id(path)
	emit_signal("scene_loaded", level_id)

	_play_level_music(level_id)

	tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)
	await tween.finished
	emit_signal("transition_finished")


func _play_level_music(level_id: String) -> void:
	if level_id == "":
		_stop_music()
		return
	
	var music_path = _level_music.get(level_id, "")

	if music_path == "":
		_stop_music()
		return

	if music_path == _current_music and _music_player.playing:
		return

	if _music_player.playing:
		_music_player.stop()

	_current_music = music_path
	var stream = load(music_path)
	if stream == null:
		push_error("Failed to load music: " + music_path)
		return
	
	if stream is AudioStreamMP3:
		stream.loop = true
	
	_music_player.stream = stream
	_music_player.play()


func _stop_music() -> void:
	if _music_player.playing:
		var tween = create_tween()
		tween.tween_property(_music_player, "volume_db", -40.0, MUSIC_FADE_DURATION)
		tween.tween_callback(_music_player.stop)
		tween.tween_callback(func(): _music_player.volume_db = MUSIC_VOLUME_DB)
		_current_music = ""


func _extract_level_id(path: String) -> String:
	var filename = path.get_file().get_basename()
	if GameData.level_exists(filename):
		return filename
	return ""
