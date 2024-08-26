extends Node3D

@onready var airplane: CharacterBody3D = $Airplane

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalAudio.start_music_theme()
	airplane.target_speed = 0.01

# Called when an input event is detected.
func _input(event: InputEvent) -> void:

	# go to in-game when anything is pressed
	if event is InputEventMouseButton or event is InputEventKey:
		
		# first level will be a  plane level at the air craft carrier for now
		GameManager.set_current_level(1, "Plane", "AircraftCarrier")
		SceneTransition.change_scene("res://Levels/PlaneLevel.tscn")
