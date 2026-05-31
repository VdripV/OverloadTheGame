extends Control

@onready var play_button:     Button = $PlayButton
@onready var settings_button: Button = $SettingsButton
@onready var stats_button:    Button = $StatsButton
@onready var quit_button:     Button = $QuitButton
@onready var video:           VideoStreamPlayer = $VideoStreamPlayer

const GAME_SCENE = "res://Map/template_map_scene.tscn"
const SETTINGS_SCENE = "res://UI/Scenes/settings.tscn"
const STATS_SCENE = "res://UI/Scenes/statistics.tscn"

func _ready() -> void:
	var cursor = load("res://UI/Assets/Video/cursor.png")
	Input.set_custom_mouse_cursor(cursor)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	video.play()
	video.finished.connect(func(): video.play())
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	stats_button.pressed.connect(_on_stats_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_settings_pressed() -> void:
	var settings = load(SETTINGS_SCENE).instantiate()
	get_tree().root.add_child(settings)

func _on_stats_pressed() -> void:
	get_tree().change_scene_to_file(STATS_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()
