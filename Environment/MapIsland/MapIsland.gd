extends Node3D

var world_sky_hack: PackedScene = load("res://Environment/Sky/examples/Sky.tscn")

func _ready():
	add_child(world_sky_hack.instantiate())

func is_player_on_landing_pad() -> bool:
	return false
	
func are_all_gates_passed() -> bool:
	return false
