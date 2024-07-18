extends CharacterBody3D

var min_flight_speed: int = 12 # Can't fly below this speed
var max_flight_speed: int = 15 # Maximum airspeed
var turn_speed: float = 0.75 # Turn rate
var pitch_speed: float = 0.5 # Climb/dive rate
var level_speed: float = 3.0 # Wings "autolevel" speed
var throttle_delta: int = 15 # Throttle change speed
var acceleration: float = 5.0 # Acceleration/deceleration
var forward_speed: float = 0.0 # Current speed
var target_speed: float = 0 # Throttle input speed

var turn_input: float = 0.0
var pitch_input: float = 0.0

# trail particles once our plane starts going faster
var air_particles_left: GPUParticles3D
var air_particles_right: GPUParticles3D

var air_particles_scene: PackedScene = load("res://Plane/PlaneParticleTrail.tscn")

@onready var plane_mesh: Node3D = $Plane_Mesh

func _ready() -> void:
	self.velocity = Vector3.ZERO
	
	# particles come from wings with max speed
	# dynamically created since they are attached to mesh
	create_air_particles() 


func create_air_particles():
	# position manually done. probably better way to do this
	air_particles_right = air_particles_scene.instantiate()
	air_particles_right.position.x = -3.5
	air_particles_right.position.y = -0.5
	air_particles_right.position.z = -1.5
	plane_mesh.add_child(air_particles_right)
	
	air_particles_left = air_particles_scene.instantiate()
	air_particles_left.position.x = 3.5
	air_particles_left.position.y = -0.5
	air_particles_left.position.z = -1.5
	plane_mesh.add_child(air_particles_left)


func _process(delta: float) -> void:
	# rotate propellor based off forward speed
	var propellor_speed_multiplier: float = 3.0
	var rotate_amount = delta * forward_speed * propellor_speed_multiplier
	plane_mesh.get_node("Propellor").rotate( Vector3.FORWARD, rotate_amount)
	
	# turn on air particle trail on wings when we are going max speed!
	air_particles_left.emitting = target_speed == max_flight_speed
	air_particles_right.emitting = target_speed == max_flight_speed

func _physics_process(delta: float) -> void:
	
	get_input(delta)
	
	# change pitch. If we are on the ground, we cannot make our pitch negative to look underground
	if is_on_floor():
		pitch_input = maxf(pitch_input, 0.0) # cannot look down if we are grounded
		if min_flight_speed > forward_speed:
			pitch_input = 0.0 # cannot pitch up if going below mininum flight speed

	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)

	# turn logic
	transform.basis = transform.basis.rotated(Vector3.UP, turn_input * turn_speed * delta)

	# "banking" (rotating) motion to make turning look more realistic
	if is_on_floor():
		plane_mesh.rotation.z = 0 # straighten out and don't do banking
	else:
		plane_mesh.rotation.z = lerp(plane_mesh.rotation.z, -turn_input, level_speed * delta)
	
	# accelerate/decelerate
	forward_speed = lerp(forward_speed, target_speed, acceleration * delta)

	velocity = -transform.basis.z * forward_speed # Movement is always forward
	move_and_slide()

func get_input(delta: float) -> void:
	if Input.is_action_pressed("throttle_up"):
		target_speed = min(forward_speed + throttle_delta * delta, max_flight_speed)

	if Input.is_action_pressed("throttle_down"):
		# if plane is touching ground, we can stop
		# if plane is in mid air, don't allow to stop since it looks weird
		var limit := 5
		if is_on_floor():
			limit = 0
		target_speed = max(forward_speed - throttle_delta * delta, limit)

	# Turn (roll/yaw) input. keyboard = int, controller = float
	turn_input = 0.0
	turn_input -= Input.get_action_strength("roll_right")
	turn_input += Input.get_action_strength("roll_left")
	
	# Pitch (climb/dive) input. keyboard = int, controller = float
	pitch_input = 0.0
	pitch_input += Input.get_action_strength("pitch_up")
	pitch_input -= Input.get_action_strength("pitch_down")
