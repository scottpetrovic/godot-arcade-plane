extends Node

@onready var kaiju_body: AnimatableBody3D = $".."
@export var move_distance: float = 15.0
@export var turn_angle: float = 30.0
@export var look_time: float = 6.0
@export var move_time: float = 20.0
@export var turn_time: float = 5.0

@onready var kaiju_animation_logic: Node = $"../KaijuAnimationLogic"


# emerging happens when the enemy is first created
# retreating happens when the enemy "dies" and goes into the ground
enum State { EMERGE, IDLE, MOVING, LOOKING, TURNING, RETREAT }

var current_state: State = State.EMERGE
var current_direction: Vector3
var tween: Tween

func _ready():
	# Initialize the current_direction based on the kaiju's initial rotation
	current_direction = get_forward_direction()

	kaiju_body.retreat.connect(_retreat)
	kaiju_animation_logic.done_emerging_animation.connect(_done_emerging)

func _done_emerging() -> void:
	change_state(State.IDLE)
	
func _retreat() -> void:
	change_state(State.RETREAT)

func _process(delta):
	
	# conditions that would trigger changing state
	match current_state:
		State.EMERGE:
			# we will get a signal from animation logic
			# to know when to change from this state
			pass
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
	# animations that happen with new state
	# when tweens are done, they often go to next state
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
