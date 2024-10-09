class_name FlightInstruments
extends Node

@export var airplane: CharacterBody3D

var level_angle: float = 0.0
var pitch_angle: float = 0.0
var altitude: float = 0.0
var airspeed: float = 0.0

func update() -> void:
	if airplane:
		calculate_altitude()
		calculate_airspeed()

func calculate_pitch() -> float:
	# Calculate pitch angle
	var forward_vector = -airplane.transform.basis.z
	var projected_forward = forward_vector.project(Vector3(forward_vector.x, 0, forward_vector.z))
	pitch_angle = rad_to_deg(forward_vector.angle_to(projected_forward))
	
	# Determine the sign of the pitch angle
	if forward_vector.y > 0:
		pitch_angle = -pitch_angle
		
	return pitch_angle # negative value means we are pitching to go up

func calculate_level_angle() -> int:
	var level_angle: int = int(rad_to_deg(airplane.rotation.z))
	
	# -45 to 45 degrees is acceptable angles to land
	#  if hitting landing strip outside of that...crash
	
	# 0 degrees is perfectly level
	
	# 100 - abs(level_angle*2) can be scoring criteria.
	# if abs(level_angle) is less than 3, mark as 100 (close enough)
	return abs(level_angle) # in degrees


func calculate_altitude() -> float:
	altitude = airplane.global_transform.origin.y
	return altitude

func calculate_airspeed() -> void:
	# Assuming the airplane script has a 'forward_speed' property
	airspeed = airplane.forward_speed
