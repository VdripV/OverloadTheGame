extends Node3D

@onready var debris: GPUParticles3D = $DebrisParticles
@onready var smoke: GPUParticles3D = $SmokeParticles
@onready var fire: GPUParticles3D = $FireParticles

func _ready():
	if debris:
		debris.emitting = true
	if smoke:
		smoke.emitting = true
	if fire:
		fire.emitting = true
	
	var lifeTime = 0.0
	if smoke:
		lifeTime = smoke.lifetime
	if fire and fire.lifetime > lifeTime:
		lifeTime = fire.lifetime
	if debris and debris.lifetime > lifeTime:
		lifeTime = debris.lifetime
	
	if lifeTime <= 0:
		lifeTime = 2.0
	
	await get_tree().create_timer(lifeTime).timeout
	queue_free()
