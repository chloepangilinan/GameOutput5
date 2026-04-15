extends Node3D

@export var zombie_scene: PackedScene
@export var max_zombies: int = 10
@export var spawn_interval: float = 2.0
@export var spawn_range_x: float = 30.0
@export var spawn_range_z: float = 30.0
@export var spawn_y: float = 1.0
@export var min_distance_from_player: float = 10.0

var timer: float = 0.0

@onready var player = $CharacterBody3D

func _process(delta: float) -> void:
	timer += delta

	if timer >= spawn_interval:
		timer = 0.0
		spawn_zombie()

func spawn_zombie() -> void:
	if zombie_scene == null:
		return

	if get_tree().get_nodes_in_group("zombies").size() >= max_zombies:
		return

	var spawn_position := Vector3.ZERO
	var found_valid_position := false

	for i in range(20):
		var random_x = randf_range(-spawn_range_x, spawn_range_x)
		var random_z = randf_range(-spawn_range_z, spawn_range_z)
		var test_position = Vector3(random_x, spawn_y, random_z)

		if player.global_position.distance_to(test_position) >= min_distance_from_player:
			spawn_position = test_position
			found_valid_position = true
			break

	if not found_valid_position:
		return

	var zombie = zombie_scene.instantiate()
	add_child(zombie)
	zombie.global_position = spawn_position
