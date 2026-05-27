extends RigidBody3D

@onready var bullet: MeshInstance3D = $bullet
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var collision_detection: ShapeCast3D = $CollisionDetection

var particlesScene: PackedScene = preload("res://SourceFiles/vfx/scenes/ParticlesManagerScene.tscn")
var audioScene: PackedScene = preload("res://SourceFiles/vfx/scenes/AudioManagerScene.tscn")

@export var explosionSound: AudioStream
@export var explosionRadius: float = 10.0
var Speed: int
var Damage: int
var hasExploded: bool = false

func _physics_process(delta: float) -> void:
	position += transform.basis * Vector3(0, -delta, -Speed) * delta
	if collision_detection.is_colliding():
		explode()

func _on_timer_timeout() -> void:
	queue_free()
	
func explode() -> void:
	if hasExploded:
		return
		
	hasExploded = true

	bullet.visible = false
	collision_shape.set_deferred("disabled", true)

	var particles = particlesScene.instantiate()
	get_parent().add_child(particles)
	particles.global_position = global_position

	if explosionSound != null:
		var audio = audioScene.instantiate()
		audio.global_position = global_position
		get_parent().add_child(audio)
		audio.stream = explosionSound
		audio.play()
		
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()

	var sphere = SphereShape3D.new()
	sphere.radius = explosionRadius

	query.shape = sphere
	query.transform = Transform3D.IDENTITY.translated(position)

	var results = space_state.intersect_shape(query)
	
	for result in results:
		var collider = result.get("collider")
		if  collider == null or collider == self:
			continue
			
		var distance = global_position.distance_to(collider.global_position)
		var damage = Damage * (1.0 - distance / explosionRadius)
		damage = max(damage, 0)

		if damage <= 0:
			continue

		var direction = (collider.global_position - global_position).normalized()

		if collider.is_in_group("Target") and collider.has_method("Hit_Successful"):
			collider.Hit_Successful(int(damage), direction, collider.global_position)

		if collider.is_in_group("Player") and collider.has_method("hit_with_knockback"):
			var knockbackForce = damage
			collider.hit_with_knockback(int(damage), direction, knockbackForce)
			
	queue_free()
