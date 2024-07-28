extends Area3D

var is_checked: bool = false

func _ready() -> void:
	self.body_entered.connect(body_enter)
	
func body_enter(body: Node3D) -> void:
	if body.name == "Airplane":
		is_checked = true
