

# SkidMark.gd
extends MeshInstance3D

@export var fade_time: float = 2.0
var time_alive: float = 0.0

func _ready() -> void:
	# Create a simple quad mesh
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(0.1, 0.8)  # Adjust size as needed
	mesh = plane_mesh
	

	# Create a new material
	var material = StandardMaterial3D.new()
	material.albedo_texture = preload("res://Character/SkidDecal/skid-decal.png")  # Update this path
	material.flags_transparent = true
	material.flags_unshaded = true
	material.params_billboard_mode = StandardMaterial3D.BILLBOARD_DISABLED
	material.params_cull_mode = StandardMaterial3D.CULL_DISABLED
	material.render_priority = 1  # Ensure it renders on top of the ground
	
	# Assign the material
	set_surface_override_material(0, material)

func _process(delta: float) -> void:
	time_alive += delta
	if time_alive >= fade_time:
		queue_free()
	else:
		# Fade out the skid mark over time
		var material = get_surface_override_material(0)
		if material:
			var alpha = 1.0 - (time_alive / fade_time)
			material.albedo_color = Color(1, 1, 1, alpha)
