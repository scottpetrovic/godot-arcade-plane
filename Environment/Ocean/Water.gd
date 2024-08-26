extends Area3D

func _ready() -> void:
	self.body_entered.connect(body_entered_event)

func body_entered_event(body: Node3D):
	if body.name == "Airplane" || body.name == "PlayerSkydiver":
		print('airplane crashed...in the water class')
		GameManager.find_base_node().player_crashed()
