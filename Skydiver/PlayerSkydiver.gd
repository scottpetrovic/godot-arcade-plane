extends CharacterBody3D

const SPEED: float = 8.0
const ROTATION_SPEED: float = 90.0  # Degrees per second
const FALL_SPEED: float = -10.0  # Constant fall speed
const PARACHUTE_FALL_SPEED: float = -3.0  # Reduced fall speed when parachute is active
const PARACHUTE_FORWARD_SPEED: float = 2.0  # Additional forward speed when parachute is active

@onready var parachute_mesh: Node3D = $ParachuteMesh
@onready var skydiver: Node3D = $Skydiver

var is_landed: bool = false
var has_crashed: bool = false
var is_parachute_activated: bool = false

func _ready():
	
	# free falling animation
	var animation_player: AnimationPlayer = skydiver.get_node("AnimationPlayer")
	animation_player.play("FreeFalling")



func landed():
	is_landed = true

func _physics_process(delta: float) -> void:
	
	# stop from falling or inputs
	if has_crashed || is_landed:
		return

	# Check for parachute activation.
	# once it is active, cannot undo it
	if Input.is_action_just_pressed("ui_parachute") && is_parachute_activated == false:
		is_parachute_activated = true
		parachute_mesh.visible = true
		
		var animation_player: AnimationPlayer = skydiver.get_node("AnimationPlayer")
		animation_player.play("Assembly")

	# Ensure the player is always falling at the appropriate rate.
	if is_parachute_activated:
		velocity.y = PARACHUTE_FALL_SPEED
		velocity -= transform.basis.z * PARACHUTE_FORWARD_SPEED * delta
	else:
		velocity.y = FALL_SPEED

	# Handle rotation and movement.
	if Input.is_action_pressed("ui_up"):
		rotation_degrees.x -= ROTATION_SPEED * delta
		velocity -= transform.basis.z * SPEED * delta
	elif Input.is_action_pressed("ui_down"):
		rotation_degrees.x += ROTATION_SPEED * delta
		velocity += transform.basis.z * SPEED * delta

	if Input.is_action_pressed("ui_right"):
		rotation_degrees.y -= ROTATION_SPEED * delta
	elif Input.is_action_pressed("ui_left"):
		rotation_degrees.y += ROTATION_SPEED * delta

	move_and_slide()

func crashed():
	has_crashed = true
	# we have crashed in the ground, so don't hide the player
