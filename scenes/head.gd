extends Node3D

@onready var player = $".."
@onready var camera = $"."
@onready var gun = $"../Player/Skeleton3D/BoneAttachment3D/MeshInstance3D/BulletMarker"
@onready var raycast = $Camera3D/RayCast3D
var v = Vector3()
var sns = 0.12
var bullet = preload("res://bullet.tscn")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if $"../Player/Skeleton3D/SkeletonIK3D":
		$"../Player/Skeleton3D/SkeletonIK3D".start()
		
func _process(delta: float) -> void:
	camera.rotation_degrees.x = v.x
	player.rotation_degrees.y = v.y
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if Input.is_action_just_pressed("fire"):
		shoot()
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		v.y -= (event.relative.x * sns)
		v.x -= (event.relative.y * sns)
		v.x = clamp(v.x, -40, 40)
		
func shoot():
	var b = bullet.instantiate()
	owner.add_child(b)
	
	b.global_position = gun.global_position

	if "player_velocity" in b:
		b.player_velocity = player.velocity
	
	if raycast.is_colliding():
		b.look_at(raycast.get_collision_point())
	else:
		var target = raycast.global_position + (-raycast.global_transform.basis.z * 100.0)
		b.look_at(target)
