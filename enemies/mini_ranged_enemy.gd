extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D

const SPEED = 5.0
const ATTACK_RANGE = 12.0
const DETECTION_RANGE = 50.0
const IDEAL_DISTANCE = 8.0
const INVESTIGATE_TIME = 3.0
const PATROL_SPEED = 3.0
const INVESTIGATE_SPEED = 4.0

var Damage = 3
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

var last_known_player_position : Vector3
var investigate_timer : float = 0.0

var state_timer : float = 0.0
const MAX_PATROL_TIME = 30.0
const MAX_INVESTIGATE_TIME = 15.0
const MAX_RUN_TIME = 20.0

var bullet_scene = preload("res://enemies/enemy_bullet.tscn")
var shoot_cooldown : float = 0.0
const SHOOT_COOLDOWN_TIME = 2.0

func _ready():
	add_to_group("Target")
	
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 1.0
	nav_agent.radius = 0.3
	nav_agent.path_max_distance = 50.0
	
	set_state(STATE.IDLE)

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

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = -0.1
	
	match current_state:
		STATE.IDLE:
			handle_idle_state(delta)
		STATE.RUN:
			handle_run_state(delta)
		STATE.ATTACK:
			handle_attack_state(delta)

func handle_idle_state(delta):
	velocity.x = 0
	velocity.z = 0
	move_and_slide()
	state_timer += delta
	
	if can_see_player():
		set_state(STATE.RUN)

func handle_run_state(delta):
	var player = get_player()
	if player == null:
		set_state(STATE.IDLE)
		return
	
	state_timer += delta
	
	if state_timer > MAX_RUN_TIME:
		set_state(STATE.IDLE)
		return
	
	if can_see_player():
		last_known_player_position = player.global_position
		state_timer = 0.0
	
	var target = player.global_position
	target.y = global_position.y
	var dist = global_position.distance_to(target)
	
	if dist > IDEAL_DISTANCE:
		var direction = (target - global_position)
		direction.y = 0
		direction = direction.normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		look_at(Vector3(target.x, global_position.y, target.z), Vector3.UP)
	elif dist < IDEAL_DISTANCE - 3.0:
		var direction = (global_position - target)
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
		set_state(STATE.IDLE)

func handle_attack_state(delta):
	var player = get_player()
	if player == null:
		set_state(STATE.IDLE)
		return
	
	velocity.x = 0
	velocity.z = 0
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
		set_state(STATE.IDLE)

func shoot_at_player(player):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position + (player.global_position - global_position).normalized() * 1.0
	bullet.Damage = Damage
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.look_at_from_position(global_position + bullet.direction, Vector3.UP)
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
	return dist > IDEAL_DISTANCE - 5.0 and dist < IDEAL_DISTANCE + 5.0

func Hit_Successful(damage: int, _Direction := Vector3.ZERO, _Position := Vector3.ZERO):
	Health -= damage
	
	if current_state == STATE.IDLE:
		set_state(STATE.RUN)
	
	if Health <= 0:
		queue_free()
