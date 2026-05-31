extends Area3D

@export var ammo_per_weapon: int = 30  # сколько патронов даётся каждому оружию
@export var respawn_time: float = 30.0

@onready var mesh: MeshInstance3D = $MeshInstance3D

var is_available: bool = true
var weapon_manager: Node = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if not is_available:
		return
	if not body is PlayerCharacter:
		return
	
	weapon_manager = body.get_node_or_null("CameraHolder/Camera/WeaponManager")
	if weapon_manager == null:
		push_warning("AmmoStation: WeaponManager не найден")
		return
	
	for weapon_name in weapon_manager.Weapon_List:
		weapon_manager.add_ammo(weapon_name, ammo_per_weapon)
	
	_on_picked_up()

func _on_picked_up() -> void:
	is_available = false
	if mesh:
		mesh.visible = false
	
	await get_tree().create_timer(respawn_time).timeout
	is_available = true
	if mesh:
		mesh.visible = true
