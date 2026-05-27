extends Node3D

signal Weapon_Changed
signal Update_Ammo
signal Update_Weapon_Stack


@onready var animation_player: AnimationPlayer = $FPS_Rig/AnimationPlayer
@onready var Bullet_Point: Marker3D = $FPS_Rig/Bullet_Point
@onready var Gun_Raycast: RayCast3D = $FPS_Rig/RayCast3D 
#@onready var gun_sound: AudioStreamPlayer3D = $"../../../Gunshot"
#@onready var reload_sound: AudioStreamPlayer3D = $"../../../Reload"
#@onready var pickUp_sound: AudioStreamPlayer3D = $"../../../PickUP"
#@onready var drop_sound: AudioStreamPlayer3D = $"../../../Drop"
#@onready var change_sound: AudioStreamPlayer3D = $"../../../Change"
#@onready var out_of_ammo: AudioStreamPlayer3D = $"../../../OutOfAmmo"
@onready var camera: Camera3D = %Camera


var Debug_Bullet = preload("res://PlayerCharacter/WeaponManager/bullet_debug.tscn")

var Current_Weapon = null
var Weapon_Stack = []
var Weapon_Indicator = 0
var Next_Weapon: String
var Weapon_List = {}
@export var _weapon_resources: Array[Weapon_Resource]
@export var Start_Weapons: Array[String]

enum {NULL, HITSCAN, PROJECTILE}

func _ready() -> void:
	Global.weapon = self
	Initialize(Start_Weapons)
	#pickUp_sound.stream = preload("res://audio/weaponPickUp.wav")
	#drop_sound.stream = preload("res://audio/drop.wav")
	#change_sound.stream = preload("res://audio/change_Weapon.wav")
	#out_of_ammo.stream = preload("res://audio/outOfAmmo.wav")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_up"):
		Weapon_Indicator = min(Weapon_Indicator+1, Weapon_Stack.size()-1)
		exit(Weapon_Stack[Weapon_Indicator])
		print(Current_Weapon.Weapon_Name)
	
	if event.is_action_pressed("weapon_down"):
		Weapon_Indicator = max(Weapon_Indicator-1, 0)
		exit(Weapon_Stack[Weapon_Indicator])
		print(Current_Weapon.Weapon_Name)
		
	if event.is_action_pressed("shoot"):
		shoot()
		
	if event.is_action_pressed("reload"):
		reload()
	
	if event.is_action_pressed("drop") and Weapon_Stack.size() != 1:
		drop(Current_Weapon.Weapon_Name)
	
	if event.is_action_pressed("melee"):
		melee()

func Initialize(_start_weapons: Array):
	for weapon in _weapon_resources:
		Weapon_List[weapon.Weapon_Name] = weapon
	
	for i in _start_weapons:
		Weapon_Stack.push_back(i)
	
	Current_Weapon = Weapon_List[Weapon_Stack[0]]
	emit_signal("Update_Weapon_Stack", Weapon_Stack)
	enter()

func enter():
	animation_player.queue(Current_Weapon.Activate_Anim)
	emit_signal("Weapon_Changed", Current_Weapon.Weapon_Name)
	emit_signal("Update_Ammo", [Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])
	
func exit(_next_weapon: String):
	if _next_weapon != Current_Weapon.Weapon_Name:
		if animation_player.get_current_animation() != Current_Weapon.Deactivate_Anim:
			animation_player.play(Current_Weapon.Deactivate_Anim)
			Next_Weapon = _next_weapon

func Change_Weapon(weapon_name: String):
	Current_Weapon = Weapon_List[weapon_name]
	Next_Weapon = ""
	enter()
	#change_sound.play()
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == Current_Weapon.Deactivate_Anim:
		Change_Weapon(Next_Weapon)
	
	if anim_name == Current_Weapon.Shoot_Anim && Current_Weapon.Auto_Fire == true:
		if Input.is_action_pressed("shoot"):
			shoot()
	
	if anim_name == Current_Weapon.Reload_Anim:
		Calculate_Reload()

func melee():
	if animation_player.get_current_animation() != Current_Weapon.Melee_Anim:
		animation_player.play(Current_Weapon.Melee_Anim)
		var Camera_Collision = Get_Camera_Collision(Current_Weapon.Melee_Range)
		if Camera_Collision[0]:
			var Direction = (Camera_Collision[1]-owner.global_transform.origin).normalized()
			var Hit_Indicator = Debug_Bullet.instantiate()
			var world = get_tree().get_root()
			world.add_child(Hit_Indicator)
			Hit_Scan_Damage(Camera_Collision[0], Direction, Camera_Collision[1], Current_Weapon.Melee_Damage)
			
			
func shoot():
	if Current_Weapon.Current_Ammo != 0:
		if !animation_player.is_playing():
			animation_player.play(Current_Weapon.Shoot_Anim)
			Current_Weapon.Current_Ammo -= 1
			emit_signal("Update_Ammo", [Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])
			var Camera_Collision = Get_Camera_Collision(Current_Weapon.Weapon_Range)
			match Current_Weapon.Type:
				NULL:
					print("Weapon Type Not Chosen")
				HITSCAN:
					Hit_Scan_Collision(Camera_Collision[1])
				PROJECTILE:
					Launch_Projectile()
	else:
		reload()

func reload():
	if Current_Weapon.Current_Ammo == Current_Weapon.Magazine:
		return
	elif !animation_player.is_playing():
		if Current_Weapon.Reserve_Ammo != 0:
			animation_player.play(Current_Weapon.Reload_Anim)
			#reload_sound.stream = Current_Weapon.Reload_Sounds
			#reload_sound.play()
		else:
			animation_player.play(Current_Weapon.Out_Of_Ammo_Anim)
			#out_of_ammo.play()

func Calculate_Reload():
	var Reload_Amount = min(Current_Weapon.Magazine-Current_Weapon.Current_Ammo, Current_Weapon.Magazine, Current_Weapon.Reserve_Ammo)
	Current_Weapon.Current_Ammo = Current_Weapon.Current_Ammo + Reload_Amount
	Current_Weapon.Reserve_Ammo = Current_Weapon.Reserve_Ammo - Reload_Amount
	emit_signal("Update_Ammo", [Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])
	
func Get_Camera_Collision(_weapon_range) -> Array:
	var viewport = get_viewport().get_size()
	
	var Ray_Origin = camera.project_ray_origin(viewport/2)
	var Ray_End = Ray_Origin + camera.project_ray_normal(viewport/2) * _weapon_range
	
	var New_Intersction = PhysicsRayQueryParameters3D.create(Ray_Origin, Ray_End)
	var Intersection = get_world_3d().direct_space_state.intersect_ray(New_Intersction)
	
	if not Intersection.is_empty():
		var Col_Point = [Intersection.collider, Intersection.position]
		return Col_Point
	else:
		return [null, Ray_End]

func Hit_Scan_Collision(Collision_Point):
	var Bullet_Direction = (Collision_Point - Bullet_Point.get_global_transform().origin).normalized()
	var New_Interection = PhysicsRayQueryParameters3D.create(Bullet_Point.get_global_transform().origin, Collision_Point+Bullet_Direction*2)
	
	var Bullet_Collision = get_world_3d().direct_space_state.intersect_ray(New_Interection)
	
	if Bullet_Collision:
		var Hit_Indicator = Debug_Bullet.instantiate()
		var world = get_tree().get_root()
		world.add_child(Hit_Indicator)
		Hit_Indicator.global_translate(Bullet_Collision.position)
		Hit_Scan_Damage(Bullet_Collision.collider, Bullet_Direction, Bullet_Collision.position, Current_Weapon.Damage)

func Hit_Scan_Damage(Collider, Direction, Position, _weapon_damage):
	if Collider.is_in_group("Target") and Collider.has_method("Hit_Successful"):
		Collider.Hit_Successful(_weapon_damage, Direction, Position)

func Launch_Projectile():
	var Projectile = Current_Weapon.Projectile_To_Load.instantiate()
	Projectile.position = Gun_Raycast.global_position
	Projectile.transform.basis = Gun_Raycast.global_transform.basis
	Gun_Raycast.add_child(Projectile)
	Projectile.Damage = Current_Weapon.Damage
	Projectile.Speed = Current_Weapon.Projectile_Velocity
	#gun_sound.stream = Current_Weapon.Shoot_Sounds
	#gun_sound.play()
	
func _on_pick_up_detection_body_entered(body: Node3D) -> void:
	if body.Pick_Up_Ready:
		#print(pickUp_sound)
		var Weapon_In_Stack = Weapon_Stack.find(body.weapon_name, 0)
		
		if Weapon_In_Stack == -1:
			Weapon_Stack.insert(Weapon_Indicator, body.weapon_name)
			
			Weapon_List[body.weapon_name].Current_Ammo = body.current_ammo
			Weapon_List[body.weapon_name].Reserve_Ammo = body.reserve_ammo
			
			emit_signal("Update_Weapon_Stack", Weapon_Stack)
			#pickUp_sound.play()	
			exit(body.weapon_name)
			body.queue_free()
		else:
			var remaining = add_ammo(body.weapon_name, body.current_ammo + body.reserve_ammo)
			if remaining == 0:
				body.queue_free()
			
			body.current_ammo = min(remaining, Weapon_List[body.weapon_name].Magazine)
			body.reserve_ammo = max(remaining - body.current_ammo, 0)

func drop(_name: String):
	var Weapon_Ref = Weapon_Stack.find(_name, 0)
	
	if Weapon_Ref != -1:
		Weapon_Stack.pop_at(Weapon_Ref)
		emit_signal("Update_Weapon_Stack", Weapon_Stack)
		#drop_sound.play()
		
		var Weapon_Dropped = Weapon_List[_name].Weapon_Drop.instantiate()
		Weapon_Dropped.current_ammo = Weapon_List[_name].Current_Ammo
		Weapon_Dropped.reserve_ammo = Weapon_List[_name].Reserve_Ammo
		Weapon_Dropped.set_global_transform(Bullet_Point.get_global_transform())
		var World = get_tree().get_root()
		World.add_child(Weapon_Dropped)
		
		exit(Weapon_Stack[0])

func add_ammo(_Weapon: String, Ammo: int) -> int:
	var _weapon = Weapon_List[_Weapon]
	var Required = _weapon.Max_Ammo - _weapon.Reserve_Ammo
	var Remaining = max(Ammo - Required, 0)
	
	_weapon.Reserve_Ammo += min(Ammo, Required)
	emit_signal("Update_Ammo", [Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])
	return Remaining
