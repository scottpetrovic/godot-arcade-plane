extends Node

@onready var kaiju_body: AnimatableBody3D = $".."
@export var move_distance: float = 5.0
@export var turn_angle: float = 30.0
@export var look_time: float = 6.0
@export var move_time: float = 5.0
@export var turn_time: float = 5.0

enum State { IDLE, MOVING, LOOKING, TURNING }

var current_state: State = State.IDLE
var current_direction: Vector3
var tween: Tween

func _ready():
	# Initialize the current_direction based on the kaiju's initial rotation
	current_direction = get_forward_direction()

func _process(delta):
	match current_state:
		State.IDLE:
			change_state(State.MOVING)
		State.MOVING:
			if not tween or not tween.is_running():
				change_state(State.LOOKING)
		State.LOOKING:
			# State transition handled by timer
			pass
		State.TURNING:
			if not tween or not tween.is_running():
				change_state(State.MOVING)

func change_state(new_state: State):
	current_state = new_state
	match current_state:
		State.MOVING:
			move_kaiju()
		State.LOOKING:
			look_around()
		State.TURNING:
			turn_kaiju()

func move_kaiju():
	var target_position = kaiju_body.global_position + current_direction * move_distance
	tween = create_tween()
	tween.tween_property(kaiju_body, "global_position", target_position, move_time)

func look_around():
	print("Kaiju is looking around at position ", kaiju_body.global_position)
	get_tree().create_timer(look_time).timeout.connect(func(): change_state(State.TURNING))

func turn_kaiju():
	var turn_radians = deg_to_rad(turn_angle)
	var rotation_axis = Vector3.UP
	current_direction = current_direction.rotated(rotation_axis, turn_radians)
	
	# Calculate the new rotation based on the current_direction
	var new_transform = kaiju_body.global_transform.looking_at(kaiju_body.global_position + current_direction, Vector3.UP)
	var target_rotation = new_transform.basis.get_euler()
	
	tween = create_tween()
	tween.tween_property(kaiju_body, "global_rotation", target_rotation, turn_time)

func get_forward_direction() -> Vector3:
	return -kaiju_body.global_transform.basis.z
