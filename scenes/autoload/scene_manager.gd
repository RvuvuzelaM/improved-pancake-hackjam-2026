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
	"1-1": "res://assets/music/boss.mp3",
	"1-2": "res://assets/music/adventure.mp3",
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

	# Setup music player
	_music_player = AudioStreamPlayer.new()
	_music_player.volume_db = MUSIC_VOLUME_DB
	add_child(_music_player)

func change_scene(path: String, duration: float = 0.25):
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	await tween.finished

	get_tree().change_scene_to_file(path)

	# Wait for scene to initialize, then emit scene_loaded
	await get_tree().process_frame
	var level_id = _extract_level_id(path)
	emit_signal("scene_loaded", level_id)

	# Play level music
	_play_level_music(level_id)

	tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)
	await tween.finished
	emit_signal("transition_finished")


func _play_level_music(level_id: String) -> void:
	var music_path = _level_music.get(level_id, "")

	# If no music for this level, stop current music
	if music_path == "":
		_stop_music()
		return

	# If same music already playing, don't restart
	if music_path == _current_music and _music_player.playing:
		return

	# Play new music
	_current_music = music_path
	var stream = load(music_path)
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
