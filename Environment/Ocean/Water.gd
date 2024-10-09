extends Area3D

func _ready() -> void:
	self.body_entered.connect(body_entered_event)

func body_entered_event(body: Node3D):
	if body.name == "Airplane":
		EventBus.emit_signal("player_crashed", "water")
