extends ColorRect

var player: Node3D  # Reference to the player (airplane)
@onready var fuel_remaining_bar: ColorRect = $ColorRect/FuelRemainingBar

var full_fuel_size: int # width when fuel bar is full

func _ready() -> void:
	full_fuel_size = fuel_remaining_bar.size.x

func set_player(player_node: Node3D):
	player = player_node

func _process(delta: float) -> void:
	if player:
		var remaining_fuel_percentage: float = player.current_fuel /  player.total_fuel
		fuel_remaining_bar.size.x = full_fuel_size * remaining_fuel_percentage
