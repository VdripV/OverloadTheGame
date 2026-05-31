extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_count: int = 1
@export var spawn_interval: float = 10.0
@export var max_enemies_alive: int = 2
@export var spawn_radius: float = 3.0
@export var spawn_height: float = 6.0
@export var activation_range: float = 35.0
@export var auto_start: bool = true

var enemies_alive: int = 0
var is_active: bool = false
var player_nearby: bool = false

func _ready():
	$Timer.wait_time = spawn_interval
	
	if auto_start:
		start_spawning()

func _process(delta):
	check_player_distance()

func check_player_distance():
	var player = get_player()
	if player == null:
		return
	
	var distance = global_position.distance_to(player.global_position)
	var was_nearby = player_nearby
	player_nearby = distance < activation_range
	
	if player_nearby and not was_nearby:
		start_spawning()
	
	if not player_nearby and was_nearby:
		stop_spawning()

func get_player():
	if not is_inside_tree():
		return null
	var tree = get_tree()
	if tree == null:
		return null
	var players = tree.get_nodes_in_group("Player")
	if players.size() > 0:
		return players[0]
	return null

func start_spawning():
	is_active = true
	$Timer.start()
	if $Ring:
		$Ring.visible = true

func stop_spawning():
	is_active = false
	$Timer.stop()
	if $Ring:
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
	var offset = Vector3(cos(angle) * distance, spawn_height, sin(angle) * distance)
	
	enemy.global_position = global_position + offset
	get_parent().add_child(enemy)
	enemies_alive += 1
	
	enemy.tree_exiting.connect(_on_enemy_died)

func _on_enemy_died():
	enemies_alive -= 1
