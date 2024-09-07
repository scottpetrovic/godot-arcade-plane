extends Node3D

func _ready():
	# make the parent object visible to the radar
	get_parent().add_to_group("radar_target")
