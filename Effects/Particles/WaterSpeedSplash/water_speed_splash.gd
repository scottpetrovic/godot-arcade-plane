extends Node3D

var player: Player
var start_splash_height: float = 3.0

func _ready():
	# get rid of this if we crashed
	EventBus.player_crashed.connect(_on_player_crash)

func _on_player_crash(location: String):
	queue_free()

func _process(delta: float) -> void:

	# make sure we have a player instance before continuing
	if is_instance_valid(player) == false:
		player = GameManager.get_player()
		return

	update_splash_transform()
	
func update_splash_transform() -> void:

	# we probably haven't taken off, so don't show
	if player.flight_controller.forward_speed < player.flight_controller.takeoff_speed:
		visible = false
		return

	if player.global_position.y < start_splash_height:
		visible = true
		var target_position = player.global_position
		target_position.y = 0.1  # Keep it just above the water plane
		global_position = target_position
		calculate_splash_rotation() 
		apply_sprite_scaling()
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

func apply_sprite_scaling():
	var min_y = 0  # Assuming water level is at y = 0
	var max_y = start_splash_height  # The height at which scaling starts
	var min_scale = 0.2
	var max_scale = 5.0

	var t = 1 - clamp((player.global_position.y - min_y) / (max_y - min_y), 0, 1)
	var scale_factor = lerp(min_scale, max_scale, t)

	# Apply scaling to all child sprites
	for child in get_children():
		if child is AnimatedSprite3D:
			child.scale.y = scale_factor
