class_name HealthSystem
extends Node

var total_health: float = 100.0
var current_health: float = 100.0

func take_damage(amount: float) -> void:
	current_health -= amount

func health_percentage() -> float:
	return current_health / total_health
