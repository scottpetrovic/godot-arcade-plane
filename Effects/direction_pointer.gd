extends MeshInstance3D

var player: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	
	if is_instance_valid(player) == false:
		player = GameManager.get_player()
		return
	
	point_direction()
	
func point_direction():
	global_position = player.global_position
	global_position.y = 0.1 # just above water
	rotation_degrees.x = 90 # perm. face right direction
	rotation_degrees.z = 0
	
	var player_forward = -player.global_transform.basis.z
	player_forward.y = 0
	player_forward = player_forward.normalized()
	
	# gives direction in radians between -180 and 180
	var angle = atan2(player_forward.x, player_forward.z)
	rotation.y = angle
