extends Label

var speed_multiplier = 20.0 # magic number that looks better on UI
var player: Player  # Reference to the player (airplane)

func _process(delta: float) -> void:
	
	if is_instance_valid(player) == false:
		player = GameManager.get_player()
		return	
		
	text = str(int(player.flight_controller.forward_speed * speed_multiplier)).pad_zeros(3)# + ' MPH'
