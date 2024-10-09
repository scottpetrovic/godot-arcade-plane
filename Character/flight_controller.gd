class_name FlightController
extends Node

# Flight parameters
var takeoff_speed: int = 7 # Can't fly below this speed
var max_flight_speed: int = 12 # Maximum airspeed
var turn_speed: float = 0.35 # Turn rate when going at lower speeds
var active_turn_speed: float = turn_speed # turning rate will decrease faster plane is going
var pitch_speed: float = 0.5 # Climb/dive rate
var throttle_delta: int = 15 # Throttle change speed
var acceleration: float = 5.0 # Acceleration/deceleration

# Current flight state
var forward_speed: float = 0.0 # Current speed
var target_speed: float = 0 # Throttle input speed
var turn_input: float = 0.0
var pitch_input: float = 0.0
var enable_movement: bool = true # turn off when we complete mission

var lerp_speed_modifier: float = 3.0

# References to other nodes (set these in _ready())
var parent_body: CharacterBody3D
@export var plane_mesh: Node3D

func _ready() -> void:
	parent_body = get_parent() as CharacterBody3D


func process_flight(delta: float) -> void:
	if not enable_movement:
		return

	get_input(delta)
	update_speed(delta)
	rotate_aircraft(delta)
	update_velocity()

func get_input(delta: float) -> void:
	if Input.is_action_pressed("throttle_up"):
		target_speed = min(forward_speed + throttle_delta * delta, max_flight_speed)

	if Input.is_action_pressed("throttle_down"):
		var limit := takeoff_speed if not parent_body.is_on_floor() else 0
		target_speed = max(forward_speed - throttle_delta * delta, limit)

	# Turn (roll/yaw) input
	turn_input = Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right")
	
	# Pitch (climb/dive) input
	pitch_input = Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down")

func update_speed(delta: float) -> void:
	forward_speed = lerp(forward_speed, target_speed, acceleration * delta)

func update_velocity() -> void:
	parent_body.velocity = -parent_body.transform.basis.z * forward_speed

func rotate_aircraft(delta: float) -> void:
	update_active_turn_speed()
	
	if parent_body.is_on_floor():
		handle_ground_rotation(delta)
	else:
		handle_air_rotation(delta)

func update_active_turn_speed() -> void:
	var start_limiting_turn_speed = (forward_speed / max_flight_speed) > 0.8
	active_turn_speed = 0.4 if start_limiting_turn_speed else turn_speed

func handle_ground_rotation(delta: float) -> void:
	plane_mesh.rotation.z = lerp(plane_mesh.rotation.z, 0.0, delta * 2)
	parent_body.rotation.x = lerp(parent_body.rotation.x, 0.0, delta * 2)
	parent_body.rotation.z = lerp(parent_body.rotation.z, 0.0, delta * 2)
	
	if forward_speed > takeoff_speed and pitch_input > 0.0:
		parent_body.transform.basis = parent_body.transform.basis.rotated(parent_body.transform.basis.x, pitch_input * pitch_speed * delta)

	parent_body.transform.basis = parent_body.transform.basis.rotated(Vector3.UP, turn_input * active_turn_speed * delta)

func handle_air_rotation(delta: float) -> void:
	parent_body.transform.basis = parent_body.transform.basis.rotated(parent_body.transform.basis.x, pitch_input * pitch_speed * delta)
	parent_body.rotation.z = lerp(parent_body.rotation.z, parent_body.rotation.z + turn_input, lerp_speed_modifier * delta)

func set_allow_movement(enable: bool) -> void:
	enable_movement = enable

func is_engine_on() -> bool:
	return (forward_speed / max_flight_speed) > 0.01

func open_landing_gears(value: bool) -> void:
	plane_mesh.open_landing_gears(value)

func set_throttle(throttle_percentage: float) -> void:
	target_speed = throttle_percentage * max_flight_speed
	forward_speed = throttle_percentage * max_flight_speed

func get_forward_speed() -> float:
	return forward_speed

func get_max_flight_speed() -> float:
	return max_flight_speed
