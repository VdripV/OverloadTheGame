extends Node

var player
var weapon

var cursor_texture: Texture2D
@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

const MENU_MUSIC =  "res://UI/Assets/Sounds/Typed Signal.wav"

const NO_MUSIC_SCENES = [
	"res://UI/Scenes/cutscene.tscn",
	"res://UI/Scenes/HUD.tscn",
	"res://UI/Scenes/pause.tscn",
	"res://Map/template_map_scene.tscn",
	"res://Map/Space_arena.tscn",
	"res://Map/example_map.tscn"
]

func _ready() -> void:
	cursor_texture = load("res://UI/Assets/Video/cursor.png")
	Input.set_custom_mouse_cursor(cursor_texture)
	
	add_child(music_player)
	music_player.stream = load(MENU_MUSIC)
	music_player.bus = "Music"
	music_player.autoplay = false
	music_player.finished.connect(func(): music_player.play()) # зацикливание
	
	get_tree().root.connect("child_entered_tree", _on_scene_changed)

func _on_scene_changed(node: Node) -> void:
	await get_tree().process_frame
	var current = get_tree().current_scene
	if current == null:
		return
	
	if current.scene_file_path in NO_MUSIC_SCENES:
		music_player.stop()
	else:
		if not music_player.playing:
			music_player.play()

func _process(_delta: float) -> void:
	if Input.get_current_cursor_shape() == Input.CURSOR_ARROW:
		Input.set_custom_mouse_cursor(cursor_texture)
