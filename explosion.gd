extends Node3D

@onready var particles: GPUParticles3D = $GPUParticles3D

func _ready() -> void:
	if particles:
		particles.emitting = true
		await get_tree().create_timer(particles.lifetime + 0.2).timeout
	
	queue_free()
