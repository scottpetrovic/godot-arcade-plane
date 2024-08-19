extends CharacterBody3D

const SPEED: float = 5.0
const ROTATION_SPEED: float = 90.0  # Degrees per second
const FALL_SPEED: float = -10.0  # Constant fall speed
const PARACHUTE_FALL_SPEED: float = -3.0  # Reduced fall speed when parachute is active
const PARACHUTE_FORWARD_SPEED: float = 2.0  # Additional forward speed when parachute is active

@onready var parachute_mesh: MeshInstance3D = $ParachuteMesh

var has_crashed: bool = false

var parachute_active: bool = false

func _physics_process(delta: float) -> void:
	
	# stop from falling or inputs
	if has_crashed:
		return

	# Check for parachute activation.
	# once it is active, cannot undo it
	if Input.is_action_just_pressed("ui_parachute") && parachute_active == false:
		parachute_active = !parachute_active
		parachute_mesh.visible = true

	# Ensure the player is always falling at the appropriate rate.
	if parachute_active:
		velocity.y = PARACHUTE_FALL_SPEED
		velocity -= transform.basis.z * PARACHUTE_FORWARD_SPEED * delta
	else:
		velocity.y = FALL_SPEED

	# Handle rotation and movement.
	if Input.is_action_pressed("ui_up"):
		rotation_degrees.x -= ROTATION_SPEED * delta
		velocity += transform.basis.z * SPEED * delta
	elif Input.is_action_pressed("ui_down"):
		rotation_degrees.x += ROTATION_SPEED * delta
		velocity -= transform.basis.z * SPEED * delta

	if Input.is_action_pressed("ui_right"):
		rotation_degrees.y -= ROTATION_SPEED * delta
	elif Input.is_action_pressed("ui_left"):
		rotation_degrees.y += ROTATION_SPEED * delta

	move_and_slide()

func crashed():
	has_crashed = true
	visible = false # hide object
