extends Camera3D

# The target the camera will follow
@export var target: NodePath
# The offset distance above the target
@export var offset: Vector3 = Vector3(0, 10, 0)

# The rotation speed for the camera
var rotation_speed: float = 90.0

# change camera position slightly when parachute launched
@onready var player_skydiver: CharacterBody3D = $"../PlayerSkydiver"

func _ready():
	# Ensure the target is valid
	if not target:
		print("Target not set for camera follow script.")
		return

func _process(delta: float) -> void:
	if not target:
		return

	# Get the target node
	var target_node: Node3D = get_node(target)
	if target_node:
		# Calculate the new camera position
		var target_position = target_node.global_transform.origin
		var new_camera_position = target_position + offset

		# Update the camera's position
		global_transform.origin = new_camera_position

		# Handle camera rotation based on input
		# if player_skydiver.is_parachute_activated:
		if Input.is_action_pressed("ui_left"):
			rotate_y(deg_to_rad(rotation_speed * delta))
		elif Input.is_action_pressed("ui_right"):
			rotate_y(deg_to_rad(-rotation_speed * delta))
