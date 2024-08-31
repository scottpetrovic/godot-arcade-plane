extends Camera3D

@onready var airplane: CharacterBody3D = $"../Airplane"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	transform.origin.y += delta * 0.02
	look_at(airplane.global_position, Vector3.UP)
