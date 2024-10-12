extends Node3D

@export var wake_width: float = 2.0
@export var wake_length: float = 4.0
@export var particle_lifetime: float = 2.0
@export var particle_amount: int = 1000
@export var emission_box_height: float = 0.1

@onready var particles: GPUParticles3D = $GPUParticles3D

func _ready():
	update_wake_properties()

func update_wake_properties():
	if particles:
		particles.amount = particle_amount
		particles.lifetime = particle_lifetime
		
		var material: ParticleProcessMaterial = particles.process_material
		if material:
			material.emission_box_extents = Vector3(wake_width / 2, emission_box_height, 0.1)
			material.direction = Vector3(0, 0, 1)
			material.spread = 15.0
			material.gravity = Vector3(0, -0.1, 0)
			material.initial_velocity_min = wake_length / particle_lifetime
			material.initial_velocity_max = wake_length / particle_lifetime * 1.5
		
		var mesh: QuadMesh = particles.draw_pass_1
		if mesh:
			mesh.size = Vector2(wake_width / 20, wake_width / 20)  # Adjust particle size relative to wake width

func _process(delta):
	global_transform = get_parent().global_transform

# Call this function if you need to update properties at runtime
func set_wake_properties(new_width: float, new_length: float, new_lifetime: float, new_amount: int):
	wake_width = new_width
	wake_length = new_length
	particle_lifetime = new_lifetime
	particle_amount = new_amount
	update_wake_properties()
