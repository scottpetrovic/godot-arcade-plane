extends Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_area_entered)

func _area_entered(_area: Area3D) -> void:
	if _area.name == "Bullet":
		EventBus.emit_signal("player_attacked_from_behind")
