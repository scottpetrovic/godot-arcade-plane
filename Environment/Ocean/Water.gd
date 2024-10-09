extends Area3D

func _ready() -> void:
	self.body_entered.connect(body_entered_event)

func body_entered_event(body: Node3D):
	if body.is_class("Player"):
		EventBus.emit_signal("player_crashed", "water")
