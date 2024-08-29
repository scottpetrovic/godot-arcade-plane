extends Node3D

@onready var area_3d: Area3D = $Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_3d.body_entered.connect(on_body_enter)


func on_body_enter(body: Node3D):
	if body.name == "PlayerSkydiver":
		var distance = body.global_transform.origin.distance_to(self.global_position)		
		var points = 10.0 / float(distance)
		EventBus.emit_signal("skydiver_landed_on_target", points)
