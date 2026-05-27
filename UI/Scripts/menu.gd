extends Control

@onready var play_button:     Button = $Buttons/PlayButton
@onready var settings_button: Button = $Buttons/SettingsButton
@onready var stats_button:    Button = $Buttons/StatsButton
@onready var quit_button:     Button = $Buttons/QuitButton

const GAME_SCENE = "res://Map/template_map_scene.tscn"
const SETTINGS_SCENE = "res://UI/Scenes/settings.tscn"

func _ready() -> void:
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
	# Заглушка
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()
