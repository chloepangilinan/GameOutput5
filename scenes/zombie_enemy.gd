extends CharacterBody3D

const SPEED := 4.0
const MAX_HEALTH := 3

var health := MAX_HEALTH
var is_dead := false
var is_hurt := false

@onready var player = $"../CharacterBody3D"
@onready var anim_player: AnimationPlayer = $AnimationPlayer2
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var zombie_visual: Node3D = $Zombie
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var mesh_nodes: Array[MeshInstance3D] = []
var original_colors: Dictionary = {}

func _ready() -> void:
	add_to_group("zombies")
	_collect_meshes(zombie_visual)

	if anim_player:
		if anim_player.has_animation("mixamo_com_001"):
			var run_anim = anim_player.get_animation("mixamo_com_001")
			if run_anim:
				run_anim.loop_mode = Animation.LOOP_LINEAR
			anim_player.play("mixamo_com_001")
		else:
			print("Run animation mixamo_com_001 not found")
	else:
		print("AnimationPlayer2 not found")

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	if player == null:
		return

	var direction: Vector3 = player.global_position - global_position
	direction.y = 0.0

	if direction.length() > 0.05:
		direction = direction.normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		look_at(
			Vector3(player.global_position.x, global_position.y, player.global_position.z),
			Vector3.UP
		)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()

func take_damage(amount: int = 1) -> void:
	if is_dead:
		return

	health -= amount
	_flash_red()

	if health <= 0:
		die()
	else:
		play_hurt_animation()

func play_hurt_animation() -> void:
	if is_dead or is_hurt:
		return

	if anim_player == null:
		return

	if anim_player.has_animation("mixamo_com"):
		is_hurt = true
		anim_player.play("mixamo_com")
		await anim_player.animation_finished
		is_hurt = false

	if not is_dead and anim_player.has_animation("mixamo_com_001"):
		anim_player.play("mixamo_com_001")

func die() -> void:
	if is_dead:
		return

	is_dead = true
	remove_from_group("zombies")
	velocity = Vector3.ZERO

	if collision_shape:
		collision_shape.set_deferred("disabled", true)

	if nav_agent:
		nav_agent.set_physics_process(false)

	# Optional: play a death animation first if you have one
	if anim_player and anim_player.has_animation("mixamo_com_002"):
		anim_player.play("mixamo_com_002")
		await get_tree().create_timer(0.35).timeout

	await _crumble_and_disappear()

func _crumble_and_disappear() -> void:
	# Make it look darker before collapsing
	for mesh in mesh_nodes:
		for i in range(mesh.get_surface_override_material_count()):
			var mat = mesh.get_surface_override_material(i)
			if mat == null:
				var base_mat = mesh.mesh.surface_get_material(i) if mesh.mesh != null else null
				if base_mat != null:
					mat = base_mat.duplicate()
					mesh.set_surface_override_material(i, mat)

			if mat is StandardMaterial3D:
				mat.albedo_color = Color(0.25, 0.05, 0.05)

	var tween = create_tween()
	tween.set_parallel(true)

	# Tilt/fall sideways
	tween.tween_property(zombie_visual, "rotation_degrees:x", zombie_visual.rotation_degrees.x + 85.0, 0.45)
	tween.tween_property(zombie_visual, "rotation_degrees:z", zombie_visual.rotation_degrees.z + 20.0, 0.45)

	# Sink a bit
	tween.tween_property(zombie_visual, "position:y", zombie_visual.position.y - 0.6, 0.45)

	# Shrink like crumbling
	tween.tween_property(zombie_visual, "scale", Vector3(0.15, 0.15, 0.15), 0.45)

	await tween.finished
	queue_free()

func _flash_red() -> void:
	for mesh in mesh_nodes:
		var surface_count = mesh.mesh.get_surface_count() if mesh.mesh != null else 0

		for i in range(surface_count):
			var mat = mesh.get_surface_override_material(i)
			if mat == null:
				var base_mat = mesh.mesh.surface_get_material(i)
				if base_mat != null:
					mat = base_mat.duplicate()
					mesh.set_surface_override_material(i, mat)

			if mat is StandardMaterial3D:
				var key = str(mesh.get_instance_id()) + "_" + str(i)
				if not original_colors.has(key):
					original_colors[key] = mat.albedo_color
				mat.albedo_color = Color(1.0, 0.15, 0.15)

	await get_tree().create_timer(0.12).timeout

	for mesh in mesh_nodes:
		var surface_count = mesh.mesh.get_surface_count() if mesh.mesh != null else 0

		for i in range(surface_count):
			var mat = mesh.get_surface_override_material(i)
			if mat is StandardMaterial3D:
				var key = str(mesh.get_instance_id()) + "_" + str(i)
				if original_colors.has(key):
					mat.albedo_color = original_colors[key]

func _collect_meshes(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			mesh_nodes.append(child)
		_collect_meshes(child)
