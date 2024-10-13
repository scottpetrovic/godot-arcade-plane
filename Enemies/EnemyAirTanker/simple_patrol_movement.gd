class_name SimplePatrolMovement
extends Node

@onready var enemy: CharacterBody3D = $".."

@export var patrol_speed = 6.0  # Units per second
@export var turn_angle = 30.0  # Degrees
@export var distance_to_travel = 60.0  # Units
var current_distance = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	patrol_movement(delta)


func patrol_movement(delta):
	pass
	
	# Move in the current direction
	#enemy.velocity = -enemy.global_transform.basis.z # * patrol_speed
	#enemy.move_and_slide()
		
	# Keep track of distance traveled for turning
	#current_distance += patrol_speed * delta
		
	# Turn after traveling the set distance
	#if current_distance >= distance_to_travel:
	#	await turn()
	#	current_distance = 0.0
		
func turn():
	var target_rotation = 0.0
	target_rotation = enemy.rotation.y + deg_to_rad(turn_angle)
	
	# Create a tween for smooth rotation
	var turn_duration = 2.0
	var tween = create_tween()
	tween.tween_property(enemy, "rotation:y", target_rotation, turn_duration)
	
	await tween.finished
