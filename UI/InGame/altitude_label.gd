extends Label

var player: Node3D  # Reference to the player (airplane)

func _process(delta: float) -> void:
	
	if is_instance_valid(player) == false:
		player = GameManager.get_player()
		return	

	var altitude_multiplier = 5.0 # magic number that looks better on UI
	var altitude_string = str(int(player.get_node("FlightInstruments").calculate_altitude() * altitude_multiplier))
	text = altitude_string.pad_zeros(5) # + ' FT'
