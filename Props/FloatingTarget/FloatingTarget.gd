extends Area3D

signal target_completed

var is_completed = false
var material: StandardMaterial3D

func _ready():
	# Create and assign a new material
	material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0, 0)  # Initial color (red)
	$MeshInstance3D.material_override = material

func complete_target():
	is_completed = true
	$MeshInstance3D.material_override.albedo_color = Color(0, 1, 0)  # Change color to green
	emit_signal("target_completed")
	# Optional: play a sound or particle effect here

func hit():
	# This function is called by the bullet
	if not is_completed:
		complete_target()