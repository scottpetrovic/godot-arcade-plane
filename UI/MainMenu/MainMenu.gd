extends Node3D

@export var airplane: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalAudio.start_music_theme()
	airplane.flight_controller.target_speed = 0.01

# Called when an input event is detected.
func _input(event: InputEvent) -> void:
	
	# bypass selections for now and just go to airplane and aircraft carrier level
	if event is InputEventMouseButton or event is InputEventKey:
		GameManager.set_current_map(Constants.MAP.AIRCRAFTCARRIER)
		GameManager.go_to_next_level()
	return

	# go to in-game when anything is pressed
	if event is InputEventMouseButton or event is InputEventKey:
		GameManager.go_to_map_selection()
