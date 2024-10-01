extends Node3D

var player: Node3D

func _process(delta: float) -> void:
	
	if is_instance_valid(player) == false:
		player = GameManager.get_player()
		return
	
	update_splash_transform()
	
func update_splash_transform() -> void:

	if player.global_position.y < 2:
		visible = true
		var target_position = player.global_position
		target_position.y = 0.1  # Keep it just above the water plane
		global_position = target_position
		calculate_splash_rotation() 
	else:
		visible = false

func calculate_splash_rotation() -> void:
	# only need to calculate one direction
	rotation_degrees.x = 0 
	rotation_degrees.z = 0
	
	# Get player's forward direction
	var player_forward = -player.global_transform.basis.z
	player_forward.y = 0
	player_forward = player_forward.normalized()

	# Calculate rotation to face player's direction
	var target_rotation = atan2(player_forward.x, player_forward.z)

	# gives direction in radians between -180 and 180
	var angle = atan2(player_forward.x, player_forward.z)
	rotation.y = angle + (PI/2)
