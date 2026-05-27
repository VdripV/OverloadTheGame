extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D

@export var patrol_path : Node3D

const SPEED = 5.5
const ATTACK_RANGE = 3.0
const DETECTION_RANGE = 20.0
const INVESTIGATE_TIME = 3.0
const PATROL_SPEED = 3.0
const INVESTIGATE_SPEED = 4.5

var Damage = 25
var Health = 3

enum STATE {
	IDLE,
	PATROL,
	INVESTIGATE,
	RUN,
	ATTACK,
	DEATH
}

var current_state : STATE = STATE.IDLE

var patrol_points : Array = []
var current_patrol_index : int = 0
var patrol_wait_timer : float = 0.0
var last_known_player_position : Vector3
var investigate_timer : float = 0.0

var state_timer : float = 0.0
const MAX_PATROL_TIME = 30.0
const MAX_INVESTIGATE_TIME = 15.0
const MAX_RUN_TIME = 20.0

func _ready() -> void:
	add_to_group("Target")
	if patrol_path != null:
		for child in patrol_path.get_children():
			if child is Node3D:
				patrol_points.append(child.global_position)
	
	if patrol_points.size() > 0:
		set_state(STATE.PATROL)
	else:
		set_state(STATE.IDLE)
	
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 1.0
	nav_agent.radius = 0.4
	nav_agent.path_max_distance = 50.0

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

func _physics_process(delta: float) -> void:
	# Гравитация
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = -0.1
	
	match current_state:
		STATE.IDLE:
			handle_idle_state(delta)
		STATE.PATROL:
			handle_patrol_state(delta)
		STATE.INVESTIGATE:
			handle_investigate_state(delta)
		STATE.RUN:
			handle_run_state(delta)
		STATE.ATTACK:
			handle_attack_state()

func handle_idle_state(delta: float) -> void:
	velocity.x = 0
	velocity.z = 0
	move_and_slide()
	state_timer += delta
	
	if can_see_player():
		set_state(STATE.RUN)
	
	if patrol_points.size() > 0:
		patrol_wait_timer += delta
		if patrol_wait_timer > 3.0:
			patrol_wait_timer = 0.0
			set_state(STATE.PATROL)

func handle_patrol_state(delta: float) -> void:
	state_timer += delta
	
	if patrol_points.is_empty():
		set_state(STATE.IDLE)
		return
	
	if can_see_player():
		patrol_wait_timer = 0.0
		set_state(STATE.RUN)
		return
	
	var target = patrol_points[current_patrol_index]
	var dist = global_position.distance_to(target)
	
	if dist > 1.5:
		var direction = (target - global_position)
		direction.y = 0
		direction = direction.normalized()
		velocity.x = direction.x * PATROL_SPEED
		velocity.z = direction.z * PATROL_SPEED
		look_at(Vector3(target.x, global_position.y, target.z), Vector3.UP)
		patrol_wait_timer = 0.0
	else:
		velocity.x = 0
		velocity.z = 0
		patrol_wait_timer += delta
		
		if patrol_wait_timer > 2.0:
			patrol_wait_timer = 0.0
			current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
			state_timer = 0.0
	
	move_and_slide()

func handle_investigate_state(delta: float) -> void:
	state_timer += delta
	
	if state_timer > MAX_INVESTIGATE_TIME:
		state_timer = 0.0
		investigate_timer = 0.0
		if patrol_points.size() > 0:
			set_state(STATE.PATROL)
		else:
			set_state(STATE.IDLE)
		return
	
	var target = last_known_player_position
	var dist = global_position.distance_to(target)
	
	if dist > 1.5:
		var direction = (target - global_position)
		direction.y = 0
		direction = direction.normalized()
		velocity.x = direction.x * INVESTIGATE_SPEED
		velocity.z = direction.z * INVESTIGATE_SPEED
		look_at(Vector3(target.x, global_position.y, target.z), Vector3.UP)
	else:
		velocity.x = 0
		velocity.z = 0
		investigate_timer += delta
		
		if investigate_timer > INVESTIGATE_TIME:
			investigate_timer = 0.0
			if patrol_points.size() > 0:
				set_state(STATE.PATROL)
			else:
				set_state(STATE.IDLE)
	
	move_and_slide()
	
	if can_see_player():
		investigate_timer = 0.0
		set_state(STATE.RUN)

func handle_run_state(delta: float) -> void:
	var player = get_player()
	if player == null:
		set_state(STATE.IDLE)
		return
	
	state_timer += delta
	
	if state_timer > MAX_RUN_TIME:
		state_timer = 0.0
		last_known_player_position = player.global_position
		set_state(STATE.INVESTIGATE)
		return
	
	if can_see_player():
		last_known_player_position = player.global_position
		state_timer = 0.0
	
	var target = player.global_position
	var dist = global_position.distance_to(target)
	
	if dist > ATTACK_RANGE:
		var direction = (target - global_position)
		direction.y = 0
		direction = direction.normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		look_at(Vector3(target.x, global_position.y, target.z), Vector3.UP)
	else:
		velocity.x = 0
		velocity.z = 0
		set_state(STATE.ATTACK)
		return
	
	move_and_slide()
	
	if not can_see_player():
		set_state(STATE.INVESTIGATE)

func handle_attack_state() -> void:
	var player = get_player()
	if player == null:
		set_state(STATE.IDLE)
		return
	
	velocity.x = 0
	velocity.z = 0
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	move_and_slide()
	
	# Наносим урон
	if target_in_range():
		_hit_finished()
	
	# Ждем перед следующей атакой
	await get_tree().create_timer(1.0).timeout
	
	# Проверяем что делать дальше
	if not target_in_range():
		if can_see_player():
			set_state(STATE.RUN)
		else:
			last_known_player_position = player.global_position
			set_state(STATE.INVESTIGATE)

func set_state(new_state: STATE) -> void:
	if current_state == new_state:
		return
	
	current_state = new_state
	state_timer = 0.0

func can_see_player() -> bool:
	var player = get_player()
	if player == null:
		return false
	return global_position.distance_to(player.global_position) < DETECTION_RANGE

func target_in_range() -> bool:
	var player = get_player()
	if player == null:
		return false
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func Hit_Successful(damage: int, _Direction := Vector3.ZERO, _Position := Vector3.ZERO) -> void:
	Health -= damage
	
	if current_state == STATE.PATROL or current_state == STATE.INVESTIGATE:
		var player = get_player()
		if player:
			last_known_player_position = player.global_position
		set_state(STATE.RUN)
	
	if Health <= 0:
		queue_free()

func _hit_finished() -> void:
	var player = get_player()
	if player and global_position.distance_to(player.global_position) < ATTACK_RANGE:
		if player.has_method("hit"):
			player.hit(Damage)
			print("Враг ударил игрока! Урон: ", Damage)
