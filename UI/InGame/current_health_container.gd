extends Panel

var player: Node3D  # Reference to the player (airplane)
var full_health_size: int # width when fuel bar is full

func _ready() -> void:
	full_health_size = size.x

func _process(delta: float) -> void:
	
	if is_instance_valid(player) == false:
		player = GameManager.get_player()
		return	
	
	var player_health_perc: float = player.health_percentage()
	size.x = full_health_size * player_health_perc

func oscillate_fuel_bar(oscillate: bool) -> void:
	if oscillate:
		var scale_amount: float =  2.0 + sin(Time.get_ticks_msec()/500.0)
		scale.y = scale_amount
		return
		
	scale.y = 1.0
