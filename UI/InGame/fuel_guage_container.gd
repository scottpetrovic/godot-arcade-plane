extends Panel

var player: Player  # Reference to the player (airplane)
var full_fuel_size: int # width when fuel bar is full

func _ready() -> void:
	full_fuel_size = size.x

func _process(delta: float) -> void:
	
	if is_instance_valid(player) == false:
		player = GameManager.get_player()
		return	
	
	var remaining_fuel_percentage: float = player.fuel_system.current_fuel /  player.fuel_system.total_fuel
	size.x = full_fuel_size * remaining_fuel_percentage
	

func oscillate_fuel_bar(oscillate: bool) -> void:
	if oscillate:
		var scale_amount: float =  2.0 + sin(Time.get_ticks_msec()/500.0)
		scale.y = scale_amount
		return
		
	scale.y = 1.0
