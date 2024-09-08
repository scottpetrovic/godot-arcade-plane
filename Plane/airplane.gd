extends CharacterBody3D

var takeoff_speed: int = 7 # Can't fly below this speed
var max_flight_speed: int = 12 # Maximum airspeed
var turn_speed: float = 0.35 # Turn rate when going at lower speeds
var active_turn_speed: float = turn_speed # turning rate will decrease faster plane is going
var pitch_speed: float = 0.5 # Climb/dive rate
var lerp_speed_modifier: float = 3.0 # another turn speed
var throttle_delta: int = 15 # Throttle change speed
var acceleration: float = 5.0 # Acceleration/deceleration
var forward_speed: float = 0.0 # Current speed
var target_speed: float = 0 # Throttle input speed

var turn_input: float = 0.0
var pitch_input: float = 0.0

var enable_movement = true # turn off when we complete mission
var airplane_original_scale: float

@onready var plane_mesh: Node3D = $Plane_Mesh

func is_engine_on() -> bool:
	return (forward_speed / max_flight_speed) > 0.01

func _ready() -> void:
	self.velocity = Vector3.ZERO
	airplane_original_scale = plane_mesh.scale.y

func rotate_propellor(delta: float) -> void:
	# rotate propellor based off forward speed
	var propellor_speed_multiplier: float = 3.0
	var rotate_amount = delta * forward_speed * propellor_speed_multiplier
	plane_mesh.get_node("Propellor").rotate( Vector3.FORWARD, rotate_amount)

func _process(delta: float) -> void:
	rotate_propellor(delta)
	update_active_turn_speed()


func set_throttle(throttle_percentage: float):
	target_speed =  throttle_percentage * max_flight_speed
	forward_speed =  throttle_percentage * max_flight_speed

func update_active_turn_speed():
	
	# we need some reason to not be full speed, so reduce mobility of turning
	var start_limiting_turn_speed = (forward_speed / max_flight_speed) > 0.8
	if start_limiting_turn_speed:
		active_turn_speed = 0.4
	else:
		active_turn_speed = turn_speed

func _physics_process(delta: float) -> void:
	
	# crashed into the water
	if enable_movement == false:
		target_speed = 0
		forward_speed = 0
		return

	get_input(delta)

	# "banking" (rotating) motion to make turning look more realistic
	# if we are on the floor, straight out
	if is_on_floor():		
		plane_mesh.rotation.z = lerp(plane_mesh.rotation.z, 0.0, delta*2)
		rotation.x =  lerp(rotation.x, 0.0, delta*2)
		rotation.z = lerp(rotation.z, 0.0, delta*2)
		
		# can start pitching up once we get fast enough
		if forward_speed > takeoff_speed && pitch_input > 0.0:
			transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)

		# can turn left and right when on ground
		transform.basis = transform.basis.rotated(Vector3.UP, turn_input * active_turn_speed * delta)
	else:
		transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
		rotation.z = lerp(rotation.z, rotation.z + turn_input, lerp_speed_modifier * delta)

	
	# accelerate/decelerate
	forward_speed = lerp(forward_speed, target_speed, acceleration * delta)
	velocity = -transform.basis.z * forward_speed # Movement is always forward
	
	squash_and_stretch(delta)
	apply_gravity(delta)
	move_and_slide()

func squash_and_stretch(delta: float) -> void:
	# a bit of squash and stretch when pitching in the air
	if is_on_floor() == false:
		var scale_pitch_amount_y = airplane_original_scale
		var scale_pitch_amount_x = airplane_original_scale
		if pitch_input != 0.0:
			scale_pitch_amount_y = airplane_original_scale * 0.95
			scale_pitch_amount_x = airplane_original_scale * 1.4
		plane_mesh.scale.y = lerp(plane_mesh.scale.y, scale_pitch_amount_y, lerp_speed_modifier * delta)
		plane_mesh.scale.x = lerp(plane_mesh.scale.x, scale_pitch_amount_x, lerp_speed_modifier * delta)
	else:
		plane_mesh.scale.y = airplane_original_scale
		plane_mesh.scale.x = airplane_original_scale

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

func set_allow_movement(enable: bool):
	enable_movement = enable
	
func allow_movement() -> bool:
	return enable_movement
