extends Node

# trail particles once our plane starts going faster
var air_particles: GPUParticles3D
var air_particles_2: GPUParticles3D

var air_particles_scene: PackedScene = load("res://Effects/Particles/PlaneParticleTrail.tscn")
@export var plane_mesh: Node3D
@onready var airplane: CharacterBody3D = $".."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_air_particles() 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# turn on air particle trail on wings when we are going max speed!
	var is_going_max_speed =  airplane.get_node("FlightController").target_speed == airplane.get_node("FlightController").max_flight_speed
	air_particles.emitting = is_going_max_speed
	air_particles_2.emitting = is_going_max_speed

## particles come from wings with max speed
## dynamically created since they are attached to mesh
func create_air_particles():
	# position manually done. probably better way to do this
	air_particles = air_particles_scene.instantiate()
	air_particles.position.y = 0.2
	air_particles.position.z = 0.0
	air_particles.position.x = -0.7
	air_particles.emitting = false
	plane_mesh.add_child(air_particles)
	
	air_particles_2 = air_particles_scene.instantiate()
	air_particles_2.position.y = 0.2
	air_particles_2.position.z = 0.0
	air_particles_2.position.x = 0.7
	air_particles_2.emitting = false
	plane_mesh.add_child(air_particles_2)
