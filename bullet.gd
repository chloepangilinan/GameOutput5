extends Area3D

@export var speed: float = 60.0
var damage: int = 1
var lifetime: float = 3.0
var player_velocity: Vector3 = Vector3.ZERO
var explosion_scene = preload("res://explosion.tscn")

func _physics_process(delta: float) -> void:
	global_position += (player_velocity - global_transform.basis.z * speed) * delta
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func spawn_explosion() -> void:
	var explosion = explosion_scene.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		return
	
	if body.is_in_group("ignore_explosion"):
		queue_free()
		return

	var target: Node = body
	while target != null and not target.has_method("take_damage"):
		target = target.get_parent()

	if target != null and target.has_method("take_damage"):
		target.take_damage(damage)
	
	spawn_explosion()
	queue_free()
