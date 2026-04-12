extends Area3D

@export var speed: float = 60.0
var damage: int = 1
var lifetime: float = 3.0

func _physics_process(delta: float) -> void:
	global_position += -global_transform.basis.z * speed * delta
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	# Ignore the player so the bullet doesn't explode in your face
	if body.is_in_group("player") or body is CharacterBody3D:
		return
		
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	queue_free()
	
