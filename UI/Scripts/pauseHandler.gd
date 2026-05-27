extends Node

const PAUSE_SCENE = "res://UI/Scenes/pause.tscn"
var pause_open: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_pause"):
		if get_tree().current_scene.scene_file_path == "res://addons/UI/Scenes/menu.tscn":
			return
		if not pause_open:
			_open_pause()

func _open_pause() -> void:
	pause_open = true
	var pause = load(PAUSE_SCENE).instantiate()
	pause.tree_exited.connect(func(): pause_open = false)
	get_tree().root.add_child(pause)
