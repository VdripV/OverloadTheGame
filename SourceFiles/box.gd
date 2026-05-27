extends RigidBody3D

@export var Health: int = 3
@export var explosionSound: AudioStream
@export var explosionDamage: int = 120
@export var explosionRadius: float = 5.0

var particlesScene: PackedScene = preload("res://SourceFiles/vfx/scenes/ParticlesManagerScene.tscn")
var audioScene: PackedScene = preload("res://SourceFiles/vfx/scenes/AudioManagerScene.tscn")
var hasExploded: bool = false

func _ready():
	add_to_group("Target")

func Hit_Successful(damage: int, _Direction := Vector3.ZERO, _Position := Vector3.ZERO) -> void:
	if hasExploded:
		return
	
	Health -= damage
	
	if Health <= 0:
		explode()
		return
	
	if _Direction != Vector3.ZERO:
		apply_impulse(_Direction * damage * 0.5, _Position - global_position)

func explode():
	if hasExploded:
		return
	
	hasExploded = true
	
	$MeshInstance3D.visible = false
	$CollisionShape3D.set_deferred("disabled", true)
	
	var particles = particlesScene.instantiate()
	particles.global_position = global_position
	get_parent().add_child(particles)
	
	if explosionSound != null:
		var audio = audioScene.instantiate()
		audio.global_position = global_position
		get_parent().add_child(audio)
		audio.stream = explosionSound
		audio.play()
	
	dealExplosionDamage()
	
	queue_free()

func dealExplosionDamage():
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	
	var sphere = SphereShape3D.new()
	sphere.radius = explosionRadius
	
	query.shape = sphere
	query.transform = Transform3D.IDENTITY.translated(global_position)
	
	var results = space_state.intersect_shape(query)
	
	for result in results:
		var collider = result.get("collider")
		if collider == null or collider == self:
			continue
		
		var distance = global_position.distance_to(collider.global_position)
		var damage = explosionDamage * (1.0 - distance / explosionRadius)
		damage = max(damage, 0)
		
		if damage <= 0:
			continue
		
		var direction = (collider.global_position - global_position).normalized()
		
		if collider.is_in_group("Target") and collider.has_method("Hit_Successful"):
			collider.Hit_Successful(int(damage), direction, collider.global_position)
		
		if collider.is_in_group("Player") and collider.has_method("hit_with_knockback"):
			var knockbackForce = damage * 2.0
			collider.hit_with_knockback(int(damage), direction, knockbackForce)
