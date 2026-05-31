extends Area3D

@export var heal_amount: float = 25.0
@onready var ray_cast_3d: RayCast3D = $RayCast3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerCharacter:
		body.health += heal_amount
		queue_free()

func _physics_process(delta: float) -> void:
	if !ray_cast_3d.is_colliding():
		position.y -= delta
