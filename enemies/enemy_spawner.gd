extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_count: int = 3
@export var spawn_interval: float = 5.0
@export var max_enemies_alive: int = 5
@export var spawn_radius: float = 1.0
@export var auto_start: bool = true

var enemies_alive: int = 0
var is_active: bool = false

func _ready():
	$Timer.wait_time = spawn_interval
	
	if auto_start:
		start_spawning()

func start_spawning():
	is_active = true
	$Timer.start()
	$Ring.visible = true

func stop_spawning():
	is_active = false
	$Timer.stop()
	$Ring.visible = false

func _on_timer_timeout():
	if not is_active:
		return
	
	if enemy_scene == null:
		return
	
	if enemies_alive >= max_enemies_alive:
		return
	
	for i in range(spawn_count):
		if enemies_alive >= max_enemies_alive:
			break
		
		spawn_enemy()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	
	var angle = randf_range(0, PI * 2)
	var distance = randf_range(0, spawn_radius)
	var offset = Vector3(cos(angle) * distance, 1.0, sin(angle) * distance)
	
	enemy.global_position = global_position + offset
	
	get_parent().add_child(enemy)
	enemies_alive += 1
	
	if enemy.has_signal("tree_exiting"):
		enemy.tree_exiting.connect(_on_enemy_died.bind(enemy))

func _on_enemy_died(enemy):
	enemies_alive -= 1
