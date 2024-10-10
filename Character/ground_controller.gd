class_name GroundController
extends Node

# Ground handling parameters
var ground_friction: float = 0.995
var drift_factor: float = 0.02
var skid_threshold: float = 8.0
var max_lateral_speed: float = 2.0

# Skid mark parameters
var skid_mark_threshold: float = 1.0  # Minimum lateral speed to start creating skid marks
var mark_spawn_interval: float = 0.01  # Time between skid mark spawns
var time_since_last_mark: float = 0.0

# Current state
var lateral_velocity: Vector3 = Vector3.ZERO

# References
var parent_body: Player
var flight_controller: FlightController

# Preload the skid mark scene
@export var skid_mark_scene: PackedScene

func _ready() -> void:
	parent_body = get_parent() as Player
	flight_controller = parent_body.get_node("FlightController")

func process_ground_movement(delta: float) -> void:
	apply_ground_friction(delta)
	apply_drift_and_skid(delta)
	update_velocity()
	handle_skid_marks(delta)

func apply_ground_friction(delta: float) -> void:
	lateral_velocity *= pow(ground_friction, delta * 60)

func apply_drift_and_skid(delta: float) -> void:
	var forward_speed = flight_controller.get_forward_speed()
	var turn_input = flight_controller.turn_input
	var right_direction = parent_body.transform.basis.x
	
	var drift_velocity = right_direction * (turn_input * drift_factor * forward_speed)
	lateral_velocity += drift_velocity * delta
	
	if forward_speed > skid_threshold:
		var skid_factor = (forward_speed - skid_threshold) / (flight_controller.get_max_flight_speed() - skid_threshold)
		skid_factor = min(skid_factor, 1.0)
		lateral_velocity += right_direction * (turn_input * skid_factor * 0.5 * forward_speed * delta)
	
	if lateral_velocity.length() > max_lateral_speed:
		lateral_velocity = lateral_velocity.normalized() * max_lateral_speed

func update_velocity() -> void:
	var forward_velocity = parent_body.velocity
	var blended_velocity = forward_velocity + lateral_velocity
	parent_body.velocity = blended_velocity.normalized() * forward_velocity.length()

func handle_skid_marks(delta: float) -> void:
	time_since_last_mark += delta
	
	if lateral_velocity.length() > skid_mark_threshold and parent_body.is_on_floor():
		if time_since_last_mark >= mark_spawn_interval:
			
			# spawn a skid mark for back tire
			var back_wheel_position = parent_body.get_wheel_location("BACK")
			spawn_skid_mark(back_wheel_position)
#
			#var right_wheel_position = parent_body.get_wheel_location("RIGHT")
			#spawn_skid_mark(right_wheel_position)
			
			# this is hack since our left wheel origin point is at 0,0,0
			#var left_wheel_position = right_wheel_position
			#left_wheel_position.x += 0.5
			#spawn_skid_mark(left_wheel_position)
		
			time_since_last_mark = 0.0

func spawn_skid_mark(position_to_place: Vector3) -> void:
	if skid_mark_scene:
		var skid_mark = skid_mark_scene.instantiate()
		get_tree().current_scene.add_child(skid_mark)
	
		position_to_place.y = 0.04
		skid_mark.global_transform.origin = position_to_place
		
		# Orient the skid mark to match the ground and the direction of travel
		var ground_normal = get_ground_normal(position_to_place)
		var travel_direction = -parent_body.global_transform.basis.z
		skid_mark.global_transform = align_with_normal_and_direction(skid_mark.global_transform, ground_normal, travel_direction)




func get_ground_normal(position: Vector3) -> Vector3:
	var space_state = parent_body.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(position + Vector3.UP, position + Vector3.DOWN * 2)
	var result = space_state.intersect_ray(query)
	
	if result:
		return result.normal
	return Vector3.UP

func align_with_normal_and_direction(transform: Transform3D, normal: Vector3, direction: Vector3) -> Transform3D:
	transform.basis.y = normal
	transform.basis.z = direction.slide(normal).normalized()
	transform.basis.x = transform.basis.y.cross(transform.basis.z)
	transform.basis = transform.basis.orthonormalized()
	return transform

func reset_lateral_velocity() -> void:
	lateral_velocity = Vector3.ZERO
