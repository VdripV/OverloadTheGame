extends CharacterBody3D

class_name PlayerCharacter

signal health_changed(current: float, max_health: float)
signal armor_changed(current: float, max_armor: float)
signal sprint_state_changed(is_sprinting: bool)

@export var max_health: float = 100.0
@export var max_armor: float = 100.0
var health: float = 100.0 : set = set_health
var armor: float = 0.0 : set = set_armor

var is_dead: bool = false
var invincible: bool = false
@export var invincible_time: float = 1.0

@export_group("Movement variables")
var move_speed: float
var move_accel: float
var move_deccel: float
var input_direction: Vector2
var move_direction: Vector3
var desired_move_speed: float
@export var desired_move_speed_curve: Curve
@export var max_desired_move_speed: float = 30.0
@export var in_air_move_speed_curve: Curve
@export var hit_ground_cooldown: float = 0.1
var hit_ground_cooldown_ref: float
@export var bunny_hop_dms_incre: float = 3.0
@export var auto_bunny_hop: bool = false
var last_frame_position: Vector3
var last_frame_velocity: Vector3
var was_on_floor: bool
var walk_or_run: String = "WalkState"
@export var base_hitbox_height: float = 2.0
@export var base_model_height: float = 1.0
@export var height_change_duration: float = 0.15

@export_group("Crouch variables")
@export var crouch_speed: float = 6.0
@export var crouch_accel: float = 12.0
@export var crouch_deccel: float = 11.0
@export var continious_crouch: bool = false
@export var crouch_hitbox_height: float = 1.2
@export var crouch_model_height: float = 0.6

@export_group("Walk variables")
@export var walk_speed: float = 9.0
@export var walk_accel: float = 11.0
@export var walk_deccel: float = 10.0

@export_group("Run variables")
@export var run_speed: float = 12.0
@export var run_accel: float = 10.0
@export var run_deccel: float = 9.0
@export var continious_run: bool = false

@export_group("Jump variables")
@export var jump_height: float = 2.0
@export var jump_time_to_peak: float = 0.3
@export var jump_time_to_fall: float = 0.25
@onready var jump_velocity: float = (2.0 * jump_height) / jump_time_to_peak
@export var jump_cooldown: float = 0.25
var jump_cooldown_ref: float
@export var nb_jumps_in_air_allowed: int = 1
var nb_jumps_in_air_allowed_ref: int
var jump_buff_on: bool = false
var buffered_jump: bool = false
@export var coyote_jump_cooldown: float = 0.3
var coyote_jump_cooldown_ref: float
var coyote_jump_on: bool = false

@export_group("Slide variables")
var slide_direction: Vector3 = Vector3.ZERO
@export var use_desired_move_speed: bool = false
@export var slide_speed: float = 12.0
@export var slide_accel: float = 23.0
@export var slide_time: float = 1.2
var slide_time_ref: float
@export var time_bef_can_slide_again: float = 1.5
var time_bef_can_slide_again_ref: float
@export_range(0.0, 90.0, 0.1) var max_slope_angle: float = 75.0
@export_range(0.0, 0.1, 0.001) var uphill_tolerance : float = 0.05
@export var amount_velocity_lost_per_sec: float = 4.0
@export var slope_sliding_dms_incre: float = 2.0
@export var slope_sliding_ms_incre: float = 2.0
@export var priority_over_crouch: bool = true
@export var continious_slide: bool = true
var slide_buff_on: bool = false
@export var slide_hitbox_height: float = 1.0
@export var slide_model_height: float = 0.5

@export_group("Dash variables")
var dash_direction: Vector3 = Vector3.ZERO
@export var dash_speed: float = 100.0
@export var dash_time: float = 0.1
var dash_time_ref: float
@export var nb_dashs_allowed: int = 3
var nb_dashs_allowed_ref: int
@export var time_bef_can_dash_again: float = 0.8
var time_bef_can_dash_again_ref: float
@export var time_bef_reload_dash: float = 3.0
var time_bef_reload_dash_ref: float
var velocity_pre_dash : Vector3
var has_dashed : bool = false

@export_group("Wallrun variables")
var can_wallrun : bool = true
var side_check_raycast_collided : int = 0
var last_wallrunned_wall_out_of_time : int = 0
var wall_normal : Vector3 = Vector3.ZERO
var wall_forward_dir : Vector3 = Vector3.ZERO
@export var use_desired_move_speed_wallrun : bool = false
@export var wallrun_speed : float = 18.0
@export var wallrun_accel : float = 2.3
@export var wallrun_deccel : float = 7.0
@export_range(0.0, 1.0, 0.001) var wallrun_fall_gravity_multiplier : float = 0.006
@export var wallrun_time : float = 3.5
var wallrun_time_ref : float 
@export var infinite_wallrun_time : bool = false
@export var time_bef_can_wallrun_again : float = 0.2
var time_bef_can_wallrun_again_ref : float
@export var wallrunning_dms_incre : float = 1.0

@export_group("Walljump variables")
var about_to_jump_vel : Vector3
@export var walljump_push_force : float = 14.0
@export var walljump_y_velocity : float = 9.0
@export var walljump_lock_in_air_movement_time : float = 0.15
var walljump_lock_in_air_movement_time_ref : float

@export_group("Fly variables")
@export var fly_speed: float = 20.0
@export var fly_accel: float = 15.0
@export var fly_deccel: float = 15.0
@export var fly_boost_multiplier: float = 3.0
var fly_boost_on: bool = false

@export_group("Gravity variables")
@onready var jump_gravity: float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity: float = (-2.0 * jump_height) / (jump_time_to_fall * jump_time_to_fall)

@export_group("Keybind variables")
@export var move_forward_action: StringName = "play_char_move_forward_action"
@export var move_backward_action: StringName = "play_char_move_backward_action"
@export var move_left_action: StringName = "play_char_move_left_ation"
@export var move_right_action: StringName = "play_char_move_right_action"
@export var run_action: StringName = "play_char_run_action"
@export var crouch_action: StringName = "play_char_crouch_action"
@export var jump_action: StringName = "play_char_jump_action"
@export var slide_action: StringName = "play_char_slide_action"
@export var dash_action: StringName = "play_char_dash_action"
@export var fly_action: StringName = "play_char_fly_action"
@onready var input_actions_list : Array[StringName] = [move_forward_action, move_backward_action, move_left_action, move_right_action, 
run_action, crouch_action, jump_action, slide_action, dash_action, fly_action]
@export var check_on_ready_if_inputs_registered : bool = true
var default_input_actions : Dictionary

@onready var cam_holder: Node3D = $CameraHolder
@onready var cam: Camera3D = %Camera
@onready var model: MeshInstance3D = $Model
@onready var hitbox: CollisionShape3D = $Hitbox
@onready var state_machine: Node = $StateMachine
@onready var hud: CanvasLayer = $HUD
@onready var ceiling_check: RayCast3D = %CeilingCheck
@onready var floor_check: RayCast3D = %FloorCheck
@onready var wallrun_floor_check : RayCast3D = %WallrunFloorCheck
@onready var slide_floor_check: RayCast3D = %SlideFloorCheck
@onready var left_wall_check : RayCast3D = %LeftWallCheck
@onready var right_wall_check : RayCast3D = %RightWallCheck

func _ready() -> void:
	Global.player = self
	add_to_group("player")
	add_to_group("Player")
	#collision_layer = 1
	#collision_mask = 65535
	
	hit_ground_cooldown_ref = hit_ground_cooldown
	jump_cooldown_ref = jump_cooldown
	jump_cooldown = -1.0
	nb_jumps_in_air_allowed_ref = nb_jumps_in_air_allowed
	coyote_jump_cooldown_ref = coyote_jump_cooldown
	slide_time_ref = slide_time
	time_bef_can_slide_again_ref = time_bef_can_slide_again
	time_bef_can_slide_again = -1.0
	time_bef_can_dash_again_ref = time_bef_can_dash_again
	time_bef_can_dash_again = -1.0
	time_bef_reload_dash_ref = time_bef_reload_dash
	time_bef_reload_dash = -1.0
	nb_dashs_allowed_ref = nb_dashs_allowed
	wallrun_time_ref = wallrun_time
	time_bef_can_wallrun_again_ref = time_bef_can_wallrun_again
	walljump_lock_in_air_movement_time_ref = walljump_lock_in_air_movement_time
	walljump_lock_in_air_movement_time = -1.0
	
	build_default_keybinding()
	input_actions_check()
	
func build_default_keybinding() -> void:
	default_input_actions = {
		move_forward_action : [Key.KEY_W, Key.KEY_UP],
		move_backward_action : [Key.KEY_S, Key.KEY_DOWN],
		move_left_action : [Key.KEY_A, Key.KEY_LEFT],
		move_right_action : [Key.KEY_D, Key.KEY_RIGHT],
		run_action : [Key.KEY_SHIFT],
		crouch_action : [Key.KEY_C],
		jump_action : [Key.KEY_SPACE],
		slide_action : [Key.KEY_C],
		dash_action : [Key.KEY_CTRL],
		fly_action : [Key.KEY_F]
	}
	
func input_actions_check() -> void:
	if check_on_ready_if_inputs_registered:
		var registered_input_actions: Array[StringName] = []
		for input_action in InputMap.get_actions():
			if input_action.begins_with(&"play_char_"):
				registered_input_actions.append(input_action)
				
		for input_action in input_actions_list:
			if input_action == &"":
				assert(false, "There's an undefined input action")
				
			if not registered_input_actions.has(input_action):
				var key_names = default_input_actions[input_action].map(func(key):
					return OS.get_keycode_string(key)
				)
				
				push_warning("'{input}' missing in InputMap, or input action wrongly named in the editor.\nAdding the '{input}' to runtime InputMap temporarily with the key/s: {keys}"
				.format({"input": input_action, "keys": String(", ").join(key_names)}))
				
				InputMap.add_action(input_action)
				for keycode in default_input_actions[input_action]:
					var input_event_key = InputEventKey.new()
					input_event_key.physical_keycode = keycode
					InputMap.action_add_event(input_action, input_event_key)
				
func _process(delta: float) -> void:
	wallrun_timer(delta)
	slide_timer(delta)
	dash_timer(delta)
	
func _physics_process(_delta: float) -> void:
	modify_physics_properties()
	move_and_slide()
	
func wallrun_timer(delta : float) -> void:
	if !can_wallrun:
		if time_bef_can_wallrun_again > 0.0: time_bef_can_wallrun_again -= delta
		else:
			if state_machine.curr_state_name != "Wallrun":
				wallrun_time = wallrun_time_ref
				can_wallrun = true
	
func slide_timer(delta: float) -> void:
	if time_bef_can_slide_again > 0.0: time_bef_can_slide_again -= delta
	else:
		if state_machine.curr_state_name != "Slide":
			slide_time = slide_time_ref
			
func dash_timer(delta: float) -> void:
	if nb_dashs_allowed < nb_dashs_allowed_ref:
		if time_bef_reload_dash > 0.0: time_bef_reload_dash -= delta
		else:
			time_bef_reload_dash = time_bef_reload_dash_ref
			nb_dashs_allowed += 1

	if time_bef_can_dash_again > 0.0: time_bef_can_dash_again -= delta
	else:
		if state_machine.curr_state_name != "Dash":
			dash_time = dash_time_ref
			
func modify_physics_properties() -> void:
	last_frame_position = global_position
	last_frame_velocity = velocity
	was_on_floor = !is_on_floor()
	
func gravity_apply(delta: float) -> void:
	if not is_on_floor():
		if velocity.y >= 0.0: velocity.y += jump_gravity * delta
		elif velocity.y < 0.0: velocity.y += fall_gravity * delta
	
func tween_hitbox_height(state_hitbox_height : float) -> void:
	var hitbox_tween: Tween = create_tween()
	if hitbox != null:
		hitbox_tween.tween_method(func(v): set_hitbox_height(v), hitbox.shape.height, 
		state_hitbox_height, height_change_duration)
	else:
		hitbox_tween.tween_interval(0.1)
	hitbox_tween.finished.connect(Callable(hitbox_tween, "kill"))

func set_hitbox_height(value: float) -> void:
	if hitbox.shape is CapsuleShape3D:
		hitbox.shape.height = value
		
func tween_model_height(state_model_height : float) -> void:
	var model_tween: Tween = create_tween()
	if model != null:
		model_tween.tween_property(model, "scale:y", 
		state_model_height, height_change_duration)
	else:
		model_tween.tween_interval(0.1)
	model_tween.finished.connect(Callable(model_tween, "kill"))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("sprint"):
		sprint_state_changed.emit(true)
	elif event.is_action_released("sprint"):
		sprint_state_changed.emit(false)

func hit(damage: int) -> void:
	if is_dead or invincible:
		return
	
	health -= damage
	emit_signal("health_changed", health, max_health)
	
	if health <= 0:
		die()
		return
	
	invincible = true
	await get_tree().create_timer(invincible_time).timeout
	invincible = false
	
func hit_with_knockback(damage: int, knockbackDirection: Vector3, knockbackForce: float) -> void:
	if is_dead:
		return
	
	health -= damage
	emit_signal("health_changed", health, max_health)
	
	velocity = knockbackDirection.normalized() * knockbackForce
	
	if health <= 0:
		die()
		return
	
	invincible = true
	await get_tree().create_timer(invincible_time).timeout
	invincible = false

func die() -> void:
	is_dead = true
	remove_from_group("player")
	remove_from_group("Player")
	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()

func set_health(value: float) -> void:
	health = clamp(value, 0.0, max_health)
	emit_signal("health_changed", health, max_health)

func set_armor(value: float) -> void:
	armor = clamp(value, 0.0, max_armor)
	emit_signal("armor_changed", armor, max_armor)
