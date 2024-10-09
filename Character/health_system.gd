class_name HealthSystem
extends Node

var total_health: float = 100.0
var current_health: float = 100.0

signal death()

func set_starting_health(value: float) -> void:
	current_health = value
	total_health = value

func take_damage(amount: float) -> void:
	current_health -= amount
	
	if current_health <= 0:
		emit_signal('death')

func health_percentage() -> float:
	return current_health / total_health
