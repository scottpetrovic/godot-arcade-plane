extends Node

@onready var enemy: CharacterBody3D = $".."

# will help us determine when we hit ground when crashing
var last_crash_position: Vector3
var crash_direction: Vector3

var is_stalled = false


func _ready() -> void:
	# Create a vector pointing 45 degrees downward in a random direction	
	# this will be the direction our enemy will crash
	var random_angle = randf_range(0.0, 2.0 * PI)
	crash_direction = Vector3(cos(random_angle),-1, sin(random_angle)).normalized()

func _process(delta: float) -> void:
	check_to_spawn_stall_fx()
	
func check_to_spawn_stall_fx():
	
	# check_if_stall() only works if we have a health system (air tanker does not)
	if check_if_stall() && is_stalled == false:
		is_stalled = true
		create_smoke_effects()

func create_smoke_effects() -> void:
	GameManager.create_stall_smoke_effects(enemy)

func crash_towards_ground() -> void:
	enemy.rotation = crash_direction
	enemy.velocity = Vector3.DOWN * 4.0 # fall from sky at constant speed
	enemy.move_and_slide()


func check_if_stall() -> bool:
	
	# only BaseEnemy class has this "hit" function
	if enemy.has_method("hit"):
		var health_perc_left: float = enemy.health_system.current_health / enemy.health_system.total_health
		if health_perc_left <= .5:
			return true

	return false

func check_if_crashed_into_ground() -> bool:

	# once we crash, we will monitor the descent rate
	# once the enemy stops descending, we will explode
	# this is needed because the final Y position will change depending
	# on the model, so cannot look for values like y == 0
	var position_y_diff = abs(enemy.global_position.y - last_crash_position.y)
	if position_y_diff < 0.01:
		return true
	else:
		last_crash_position = enemy.global_position	
	return false
