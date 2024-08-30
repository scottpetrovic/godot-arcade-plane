extends CharacterBody3D

const SPEED: float = 10.0
const ROTATION_SPEED: float = 2.0  # Degrees per second
const FALL_SPEED: float = -10.0  # Constant fall speed
const PARACHUTE_FALL_SPEED: float = -3.0  # Reduced fall speed when parachute is active
const PARACHUTE_FORWARD_SPEED: float = 3.0  # Additional forward speed when parachute is active
const PARACHUTE_ROTATION_SPEED: float = 90.0  # Degrees per second when parachute is active


@onready var parachute_mesh: Node3D = $ParachuteMesh
@onready var skydiver: Node3D = $Skydiver

var is_landed: bool = false

var is_parachute_activated: bool = false
signal parachute_deployed

var current_rotation_quaternion = Quaternion.IDENTITY

func _ready():
	# free falling animation
	var animation_player: AnimationPlayer = skydiver.get_node("AnimationPlayer")
	animation_player.play("FreeFalling")
	
	# get starting rotation in quaternion to apply rotation to later from input
	current_rotation_quaternion = Quaternion.from_euler(rotation)

func get_landed() -> bool:
	return is_landed

func landed():
	is_landed = true

func _physics_process(delta: float) -> void:
	
	# stop from falling or inputs
	# skydiver could have crashed, but we are treating it all the same
	if is_landed:
		return

	# Check for parachute activation.
	# once it is active, cannot undo it
	if Input.is_action_just_pressed("ui_parachute") && is_parachute_activated == false:
		deploy_parachute()

	# Handle rotation and movement.
	if is_parachute_activated == false:
		skydiving_movement(delta)
	else:
		parachuting_movement(delta)

	move_and_slide()

func parachuting_movement(delta: float) -> void:
	# Ensure the player is always falling at the appropriate rate.
	velocity = transform.basis.z * -PARACHUTE_FORWARD_SPEED
	velocity.y = PARACHUTE_FALL_SPEED

	# Lock rotation to face down
	rotation_degrees.x = 0

	# reset model's rotation to 0 if we were using up/down
	skydiver.rotation = Vector3.ZERO
	skydiver.rotation_degrees.y = 180 # this was original rotation

	if Input.is_action_pressed("ui_right"):
		rotation_degrees.y -= PARACHUTE_ROTATION_SPEED * delta
	elif Input.is_action_pressed("ui_left"):
		rotation_degrees.y += PARACHUTE_ROTATION_SPEED * delta


func skydiving_movement(delta: float) -> void:
	velocity.y = FALL_SPEED

	var rotation_change = Vector3.ZERO

	if Input.is_action_pressed("ui_up"):
		skydiver.rotation.x += ROTATION_SPEED * delta
		velocity -= transform.basis.z * SPEED * delta
	elif Input.is_action_pressed("ui_down"):
		skydiver.rotation.x -= ROTATION_SPEED * delta
		velocity += transform.basis.z * SPEED * delta

	if Input.is_action_pressed("ui_right"):
		rotation_change.y -= ROTATION_SPEED * delta
	elif Input.is_action_pressed("ui_left"):
		rotation_change.y += ROTATION_SPEED * delta

	# Apply rotation changes using quaternions
	var change_quaternion = Quaternion.from_euler(rotation_change)
	current_rotation_quaternion = change_quaternion * current_rotation_quaternion
	current_rotation_quaternion = current_rotation_quaternion.normalized()

	# Apply the quaternion rotation to the node
	transform.basis = Basis(current_rotation_quaternion)


func deploy_parachute():
	is_parachute_activated = true
	parachute_mesh.visible = true
	
	var animation_player: AnimationPlayer = skydiver.get_node("AnimationPlayer")
	animation_player.play("Assembly")

	emit_signal("parachute_deployed")
