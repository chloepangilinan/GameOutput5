extends CSGBox3D

var flash_time: float = 0.12
var original_albedo: Color
var box_material: StandardMaterial3D


func _ready() -> void:
	if material_override is StandardMaterial3D:
		box_material = material_override.duplicate()
		material_override = box_material
		original_albedo = box_material.albedo_color


func take_damage(amount: int = 1) -> void:
	flash_red()


func flash_red() -> void:
	if box_material == null:
		return

	box_material.albedo_color = Color(1, 0, 0, 1)

	await get_tree().create_timer(flash_time).timeout

	if box_material:
		box_material.albedo_color = original_albedo
