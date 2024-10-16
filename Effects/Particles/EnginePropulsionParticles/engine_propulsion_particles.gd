extends GPUParticles3D

@export var jet_radius: float = 0.5:
	set(value):
		jet_radius = value
		update_jet_size()

@export var length_life: float = 2.0:
	set(value):
		lifetime = length_life

func _ready():
	create_unique_resources()
	update_jet_size()
	
func create_unique_resources():
	# Create a unique process material
	if process_material:
		process_material = process_material.duplicate()
	else:
		process_material = ParticleProcessMaterial.new()
	
	# Create a unique draw pass
	if draw_pass_1:
		draw_pass_1 = draw_pass_1.duplicate()
	else:
		draw_pass_1 = SphereMesh.new()

func update_jet_size():
	if not draw_pass_1:
		push_error("No draw pass found. Please ensure a draw pass is set in the GPUParticles3D properties.")
		return

	if draw_pass_1 is SphereMesh:
		var sphere_mesh = draw_pass_1 as SphereMesh
		sphere_mesh.radius = jet_radius
		sphere_mesh.height = jet_radius * 2  # Height is diameter, so multiply by 2
	else:
		push_warning("Draw pass is not a SphereMesh. Custom scaling may not work as expected.")
