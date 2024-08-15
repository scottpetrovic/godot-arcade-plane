extends Area3D

@onready var airplane: CharacterBody3D = $"../Airplane"
@onready var world: Node3D = $".."

func _ready() -> void:
	self.body_entered.connect(body_entered_event)

func body_entered_event(body: Node3D):
	if body == airplane:
		world.player_crashed()
