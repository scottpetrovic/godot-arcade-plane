extends Camera3D

@export var player: NodePath
@export var height_offset: float = 3.0

func _ready():
	# Ensure the player node is set
	if player == null:
		print("Player node is not set for FollowCamera.")
		return

func _process(_delta: float) -> void:
	if player == null:
		return

	var player_node = get_node(player)
	if player_node == null:
		return

	# Follow the player's position with height offset
	var new_position = player_node.global_transform.origin
	new_position.y += height_offset
	global_transform.origin = new_position

	# Match the player's Y-axis rotation
	var player_rotation = player_node.rotation_degrees
	rotation_degrees.y = player_rotation.y

	# Ensure the camera looks towards the ground
	look_at(Vector3(global_transform.origin.x, 0, global_transform.origin.z), Vector3.UP)
