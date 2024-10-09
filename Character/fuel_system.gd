extends Node

var total_fuel: float = 100.0
var current_fuel: float = 100.0

func calculate_fuel_consumption(speed: float) -> void:
	if speed > 0.1:
		current_fuel -= 0.0003 * speed

func refuel(amount: float) -> void:
	current_fuel = min(current_fuel + amount, total_fuel)
