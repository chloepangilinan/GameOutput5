extends CharacterBody3D

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../Player"

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

var hits_taken: int = 0
const MAX_HITS: int = 3


func take_damage(amount: int = 1) -> void:
	hits_taken += amount
	print("Enemy hit: ", hits_taken, "/", MAX_HITS)

	if hits_taken >= MAX_HITS:
		die()


func die() -> void:
	queue_free()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if player:
		nav.target_position = player.global_position
		var next_position = nav.get_next_path_position()
		var direction = next_position - global_position
		direction.y = 0

		if direction.length() > 0.1:
			direction = direction.normalized()
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED

			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
