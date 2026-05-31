extends Area3D

const MENU_SCENE = "res://UI/Scenes/menu.tscn"
@export var level_name: String = "Level_1"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerCharacter:
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.stop_timer()
			StatsData.save_best_time(level_name, hud.get_time())
		
		await get_tree().create_timer(1.0).timeout
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file(MENU_SCENE)
