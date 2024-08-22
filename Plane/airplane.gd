extends CharacterBody3D

var takeoff_speed: int = 7 # Can't fly below this speed
var max_flight_speed: int = 12 # Maximum airspeed
var turn_speed: float = 0.75 # Turn rate
var active_turn_speed: float = turn_speed # turning rate will decrease faster plane is going
var pitch_speed: float = 0.5 # Climb/dive rate
var level_speed: float = 3.0 # Wings "autolevel" speed
var throttle_delta: int = 15 # Throttle change speed
var acceleration: float = 5.0 # Acceleration/deceleration
var forward_speed: float = 0.0 # Current speed
var target_speed: float = 0 # Throttle input speed

var turn_input: float = 0.0
var pitch_input: float = 0.0

# trail particles once our plane starts going faster
var air_particles: GPUParticles3D
var air_particles_2: GPUParticles3D

var air_particles_scene: PackedScene = load("res://Plane/PlaneParticleTrail.tscn")

var has_crashed = false # only water will make us crash
var is_engine_on = true # turn off when we complete mission
var airplane_original_scale: float

@onready var plane_mesh: Node3D = $Plane_Mesh

func _ready() -> void:
	self.velocity = Vector3.ZERO
	airplane_original_scale = plane_mesh.scale.y # TODO: clean this up
	create_air_particles() 

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

func _process(delta: float) -> void:
	
	# rotate propellor based off forward speed
	var propellor_speed_multiplier: float = 3.0
	var rotate_amount = delta * forward_speed * propellor_speed_multiplier
	plane_mesh.get_node("Propellor").rotate( Vector3.FORWARD, rotate_amount)
	
	# turn on air particle trail on wings when we are going max speed!
	var is_going_max_speed =  target_speed == max_flight_speed
	air_particles.emitting = is_going_max_speed
	air_particles_2.emitting = is_going_max_speed
	
	update_active_turn_speed()
	
func update_active_turn_speed():
	
	# we need some reason to not be full speed, so reduce mobility of turning
	var start_limiting_turn_speed = (forward_speed / max_flight_speed) > 0.8
	if start_limiting_turn_speed:
		active_turn_speed = 0.4
	else:
		active_turn_speed = turn_speed

func turn_engine_off():
	is_engine_on = false

func _physics_process(delta: float) -> void:
	
	if has_crashed || is_engine_on == false:
		return
	
	get_input(delta)

	# change pitch. If we are on the ground, we cannot make our pitch negative to look underground
	if is_on_floor():
		pitch_input = maxf(pitch_input, 0.0) # cannot look down if we are grounded
		if forward_speed < takeoff_speed:
			pitch_input = 0.0 # cannot pitch up if going below mininum flight speed

	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)

	# turn logic
	transform.basis = transform.basis.rotated(Vector3.UP, turn_input * active_turn_speed * delta)

	# "banking" (rotating) motion to make turning look more realistic
	if is_on_floor():
		plane_mesh.rotation.z = 0 # straighten out and don't do banking
	else:
		plane_mesh.rotation.z = lerp(plane_mesh.rotation.z, -turn_input, level_speed * delta)
	
	# a bit of squash and stretch when pitching in the air
	if is_on_floor() == false:
		var scale_pitch_amount_y = airplane_original_scale
		var scale_pitch_amount_x = airplane_original_scale
		if pitch_input != 0.0:
			scale_pitch_amount_y = airplane_original_scale * 0.95
			scale_pitch_amount_x = airplane_original_scale * 1.4
		plane_mesh.scale.y = lerp(plane_mesh.scale.y, scale_pitch_amount_y, level_speed * delta)
		plane_mesh.scale.x = lerp(plane_mesh.scale.x, scale_pitch_amount_x, level_speed * delta)
	else:
		plane_mesh.scale.y = airplane_original_scale
		plane_mesh.scale.x = airplane_original_scale
	
	# accelerate/decelerate
	forward_speed = lerp(forward_speed, target_speed, acceleration * delta)
	
	velocity = -transform.basis.z * forward_speed # Movement is always forward
	
	apply_gravity(delta)
	move_and_slide()


func apply_gravity(delta):
	# if we are going below minimum flight speed, slowly descend to help with collisions
	if takeoff_speed > forward_speed:
		# for simple arcade-ness, don't worry about accumulating gravity
		var magic_gravity_number := 20.0 
		velocity.y += get_gravity().y * delta * magic_gravity_number


func get_input(delta: float) -> void:
	if Input.is_action_pressed("throttle_up"):
		target_speed = min(forward_speed + throttle_delta * delta, max_flight_speed)

	if Input.is_action_pressed("throttle_down"):
		# if plane is touching ground, we can stop
		# if plane is in mid air, don't allow to stop since it looks weird
		var limit := takeoff_speed
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

# Water will call this if there is an impact
func crashed():
	has_crashed = true
	visible = false
