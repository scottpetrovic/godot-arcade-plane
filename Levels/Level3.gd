extends Node3D

@onready var airplane: CharacterBody3D = $Airplane

func _ready() -> void:
	# plane starts in mid-air, so give it some power at start
	airplane.set_throttle(0.7) # 70% full throttle 
