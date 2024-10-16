extends ColorRect

@export var full_speed_line_density = 0.3 # artistic value

var _player_reference: Player

func _ready() -> void:
	material.set_shader_parameter("line_density", full_speed_line_density)

func _process(delta: float) -> void:

	# make sure we have a player instance before continuing
	if is_instance_valid(_player_reference) == false:
		_player_reference = GameManager.get_player()
		return
	
	calculate_speed_lines()
	

func calculate_speed_lines() -> void:
	var character_throttle: float = _player_reference.flight_controller.forward_speed / _player_reference.flight_controller.max_flight_speed
	if character_throttle > 0.8:
		visible = true
	else:
		visible = false
