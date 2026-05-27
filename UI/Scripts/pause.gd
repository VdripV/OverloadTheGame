extends Control

const SETTINGS_SCENE = "res://UI/Scenes/settings.tscn"
const MENU_SCENE = "res://UI/Scenes/menu.tscn"

func _ready() -> void:

	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	$VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)

func _on_resume_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	queue_free()

func _on_settings_pressed() -> void:
	var settings = load(SETTINGS_SCENE).instantiate()
	settings.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(settings)

func _on_menu_pressed() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	queue_free()  
	get_tree().change_scene_to_file(MENU_SCENE)
