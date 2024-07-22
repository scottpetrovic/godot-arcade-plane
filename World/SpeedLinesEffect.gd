extends ColorRect

# This node will automatically apply to the camera

# airplane node has a couple variables on it to tell current speed
# and maximum speed
@onready var airplane: CharacterBody3D = $"../Airplane"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if airplane and airplane.has_crashed:
		material.set_shader_parameter("line_density", 0.0)
		return
	
	# if airplane is moving at 100% of speed, show full speed lines
	var airplane_current_speed_percentage = airplane.target_speed / airplane.max_flight_speed
	
	# these values are very artistic, so play with them in the node to see
	# what you like
	var full_line_density = 0.3
	if  airplane_current_speed_percentage > 0.8:
		material.set_shader_parameter("line_density", full_line_density * airplane_current_speed_percentage)
		return

	material.set_shader_parameter("line_density", 0.0)
