extends RigidBody3D

@export var weapon_name: String
@export var current_ammo: int
@export var reserve_ammo: int

@onready var floor_detection: RayCast3D = $FloorDetection

var Pick_Up_Ready: bool = false

func _ready() -> void:
	rotation.x = 0
	rotation.z = 0
	await get_tree().create_timer(2.0).timeout
	Pick_Up_Ready = true

func _physics_process(delta: float) -> void:
	rotation.x = 0
	rotation.z = 0
	rotation.y += delta * 1
	if !floor_detection.is_colliding():
		position.y -= 1 * delta
