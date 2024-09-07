extends Area3D

signal target_completed

var _is_completed = false
var material: StandardMaterial3D

func _ready():
	# Create and assign a new material
	material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0, 0)  # Initial color (red)
	$MeshInstance3D.material_override = material

func is_completed() -> bool:
	return _is_completed

func complete_target():
	_is_completed = true
	$MeshInstance3D.material_override.albedo_color = Color(0, 1, 0)  # Change color to green
	
	$QuickPulse.pulse()
	
	emit_signal("target_completed")
	# Optional: play a sound or particle effect here

func hit():
	# This function is called by the bullet
	if not _is_completed:
		complete_target()
