extends ColorRect

var player: Node3D  # Reference to the player (airplane)
@onready var fuel_remaining_bar: ColorRect = $ColorRect/FuelRemainingBar

var full_fuel_size: int # width when fuel bar is full

func _ready() -> void:
	full_fuel_size = fuel_remaining_bar.size.x

func find_player() -> void:
	player = GameManager.get_player()

func set_player(player_node: Node3D):
	player = player_node

func _process(delta: float) -> void:
	
	if is_instance_valid(player) == false:
		find_player()
		return	
	
	var remaining_fuel_percentage: float = player.current_fuel /  player.total_fuel
	fuel_remaining_bar.size.x = full_fuel_size * remaining_fuel_percentage
	
	# turn fuel bar red when low on fuel
	if remaining_fuel_percentage < 0.2:
		oscillate_fuel_bar(true)
		fuel_remaining_bar.color = 'b9404d' # red
	else:
		oscillate_fuel_bar(false)
		fuel_remaining_bar.color = '00be89' # green

func oscillate_fuel_bar(oscillate: bool) -> void:
	if oscillate:
		var scale_amount: float =  2.0 + sin(Time.get_ticks_msec()/500.0)
		fuel_remaining_bar.scale.y = scale_amount
		return
		
	fuel_remaining_bar.scale.y = 1.0
