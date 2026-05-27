extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D

@export var patrol_path : Node3D

const SPEED = 7.0
const ATTACK_RANGE = 15.0
const DETECTION_RANGE = 30.0
const IDEAL_DISTANCE = 12.0
const INVESTIGATE_TIME = 3.0
const PATROL_SPEED = 4.0
const INVESTIGATE_SPEED = 5.0

var Damage = 35
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

var bullet_scene = preload("res://enemies/enemy_bullet.tscn")
var shoot_cooldown : float = 0.0
const SHOOT_COOLDOWN_TIME = 1.5

func _ready():
	add_to_group("Target")
	collision_mask = 1
	
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
	nav_agent.radius = 0.5
	nav_agent.path_max_distance = 50.0

func get_player():
	if not is_inside_tree():
		return null
	var tree = get_tree()
	if tree == null:
		return null
	var players = tree.get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null

func _physics_process(delta):
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
			handle_attack_state(delta)

func handle_idle_state(delta):
	velocity = Vector3.ZERO
	move_and_slide()
	state_timer += delta
	
	if can_see_player():
		set_state(STATE.RUN)
	
	if patrol_points.size() > 0:
		patrol_wait_timer += delta
		if patrol_wait_timer > 3.0:
			patrol_wait_timer = 0.0
			set_state(STATE.PATROL)

func handle_patrol_state(delta):
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
		var direction = (target - global_position).normalized()
		velocity = direction * PATROL_SPEED
		look_at(Vector3(target.x, global_position.y, target.z), Vector3.UP)
		patrol_wait_timer = 0.0
	else:
		velocity = Vector3.ZERO
		patrol_wait_timer += delta
		
		if patrol_wait_timer > 2.0:
			patrol_wait_timer = 0.0
			current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
			state_timer = 0.0
	
	move_and_slide()

func handle_investigate_state(delta):
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
		var direction = (target - global_position).normalized()
		velocity = direction * INVESTIGATE_SPEED
		look_at(Vector3(target.x, global_position.y, target.z), Vector3.UP)
	else:
		velocity = Vector3.ZERO
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

func handle_run_state(delta):
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
	
	if dist > IDEAL_DISTANCE:
		var direction = (target - global_position).normalized()
		velocity = direction * SPEED
	elif dist < IDEAL_DISTANCE - 3.0:
		var direction = (global_position - target).normalized()
		velocity = direction * SPEED
	else:
		velocity = Vector3.ZERO
		look_at(Vector3(target.x, global_position.y, target.z), Vector3.UP)
		set_state(STATE.ATTACK)
		return
	
	look_at(Vector3(target.x, global_position.y, target.z), Vector3.UP)
	move_and_slide()
	
	if not can_see_player():
		set_state(STATE.INVESTIGATE)

func handle_attack_state(delta):
	var player = get_player()
	if player == null:
		return
	
	velocity = Vector3.ZERO
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	move_and_slide()
	
	shoot_cooldown += delta
	
	if shoot_cooldown >= SHOOT_COOLDOWN_TIME:
		shoot_cooldown = 0.0
		shoot_at_player(player)
	
	if not target_in_ideal_range():
		set_state(STATE.RUN)
		return
	
	if not can_see_player():
		last_known_player_position = player.global_position
		set_state(STATE.INVESTIGATE)

func shoot_at_player(player):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position + (player.global_position - global_position).normalized() * 1.5
	bullet.Damage = Damage
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.look_at(global_position + bullet.direction, Vector3.UP)
	get_parent().add_child(bullet)

func set_state(new_state):
	if current_state == new_state:
		return
	
	current_state = new_state
	state_timer = 0.0
	shoot_cooldown = 0.0

func can_see_player():
	var player = get_player()
	if player == null:
		return false
	return global_position.distance_to(player.global_position) < DETECTION_RANGE

func target_in_ideal_range():
	var player = get_player()
	if player == null:
		return false
	var dist = global_position.distance_to(player.global_position)
	return dist > IDEAL_DISTANCE - 4.0 and dist < IDEAL_DISTANCE + 4.0

func Hit_Successful(damage: int, _Direction := Vector3.ZERO, _Position := Vector3.ZERO):
	Health -= damage
	
	if current_state == STATE.PATROL or current_state == STATE.INVESTIGATE:
		var player = get_player()
		if player:
			last_known_player_position = player.global_position
		set_state(STATE.RUN)
	
	if Health <= 0:
		queue_free()
