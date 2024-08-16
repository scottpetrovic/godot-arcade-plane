extends Node3D

@onready var airplane: CharacterBody3D = $Airplane

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	airplane.target_speed = 0.02

# Called when an input event is detected.
func _input(event: InputEvent) -> void:

	# go to in-game when anything is pressed
	if event is InputEventMouseButton or event is InputEventKey:
		SceneTransition.change_scene("res://World/World.tscn")
