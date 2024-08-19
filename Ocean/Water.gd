extends Area3D

@onready var level_node: Node3D = $".."

func _ready() -> void:
	self.body_entered.connect(body_entered_event)

func body_entered_event(body: Node3D):
	if body.name == "Airplane" || body.name == "PlayerSkydiver":
		level_node.player_crashed()
