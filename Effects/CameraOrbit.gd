extends Camera3D

@export var target: Node3D
@export var orbit_height: float = 3.0
@export var orbit_distance: float = 5.0
@export var orbit_speed: float = 0.7

var angle: float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target:
		self.look_at(target.global_position, Vector3.UP)
		orbit_around_target(delta)
	
func orbit_around_target(delta: float) -> void:
	
	if target:
		angle += orbit_speed * delta
		var x = target.global_position.x + orbit_distance * cos(angle)
		var z = target.global_position.z + orbit_distance * sin(angle)
		var y = target.global_position.y + orbit_height
		self.global_position = Vector3(x, y, z)
