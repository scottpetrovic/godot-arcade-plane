extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(8.0).timeout
	get_tree().change_scene_to_file("res://MainMenu/MainMenu.tscn")
	
