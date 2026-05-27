extends RigidBody3D

const SPEED = 20.0
var Damage: int = 0
var direction: Vector3 = Vector3.ZERO

func _ready():
	$Timer.start()
	if $Area3D:
		$Area3D.body_entered.connect(_on_body_entered)
		$Area3D.collision_layer = 0
		$Area3D.collision_mask = 1
		$Area3D.monitoring = true
		$Area3D.monitorable = false
	collision_layer = 0
	collision_mask = 0
	gravity_scale = 0.0
	linear_damp = 0.0

func _physics_process(delta):
	position += direction * SPEED * delta

func _on_body_entered(body):
	if body.is_in_group("Player") and body.has_method("hit"):
		body.hit(Damage)
	queue_free()

func _on_timer_timeout():
	queue_free()
