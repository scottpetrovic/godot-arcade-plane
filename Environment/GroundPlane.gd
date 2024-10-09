extends StaticBody3D

@onready var area_3d: Area3D = $Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_3d.body_entered.connect(_body_entered)

func _body_entered(body: Node3D):
	if body is Player:
		EventBus.emit_signal("player_crashed", "ground")
		return
