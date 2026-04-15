extends Area3D

@export var speed: float = 60.0
var damage: int = 1
var lifetime: float = 3.0
var player_velocity: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	global_position += (player_velocity - global_transform.basis.z * speed) * delta
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") or body is StaticBody3D == false and body.has_method("take_damage") == false:
		if not body.is_in_group("zombie"): 
			return

	var target: Node = body
	while target != null and not target.has_method("take_damage"):
		target = target.get_parent()

	if target != null and target.has_method("take_damage"):
		target.take_damage(damage)
		queue_free()
	
	if body is StaticBody3D:
		queue_free()
