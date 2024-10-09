extends CharacterBody3D

# State Machine: Defines possible states for the enemy aircraft
enum State {PATROL, PURSUE, RETURN, ATTACK}  # Added ATTACK state for future implementation

@export var patrol_speed = 18.0  # Units per second
@export var pursuit_speed = 8.0  # Units per second
@export var turn_angle = 30.0  # Degrees
@export var distance_to_travel = 120.0  # Units
@export var attack_range = 30.0  # How close the enemy needs to be to attack (for future use)
@onready var simple_ai_shooter: Node = $SimpleAIShooter
@onready var line_of_sight: Area3D = $LineOfSight

var current_distance = 0.0
var current_state = State.PATROL
var player: Node3D = null
var patrol_starting_position: Vector3 = Vector3.ZERO
var player_in_line_of_sight: bool = false

var points_value: int = 214 # player gets points

signal enemy_died(enemy)

var health = 2

func hit() -> void:
	health -= 1
	
	if health <= 0:
		die()

func die():
	emit_signal("enemy_died", self)
	GameManager.add_destruction_points(points_value)
	GameManager.create_explosion(self.global_position)
	
	
	# do small screen shake to help with effect
	# strength, duration	
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player < 25:
		var main_camera: Camera3D = get_viewport().get_camera_3d()
		main_camera.get_node("ScreenShake").camera_shake_impulse(.1, 1.6)
	
	queue_free()  # The enemy removes itself from the scene

func _ready():
	name = "Air Scout"

	line_of_sight.body_entered.connect(_on_line_of_sight_body_entered)
	line_of_sight.body_exited.connect(_on_line_of_sight_body_exited)


func _on_line_of_sight_body_entered(body: Node3D):
	if body == player:
		player_in_line_of_sight = true
		current_state = State.PURSUE

func _on_line_of_sight_body_exited(body: Node3D):
	if body == player:
		player_in_line_of_sight = false
		current_state = State.RETURN

func check_for_player_if_not_exist():
	if is_instance_valid(player) == false:
		player = GameManager.get_player()

func check_for_starting_position():
	# intialize patrol position for when the 
	# enemy needs to return. Doing this in ready() 
	# seems to start as 0,0,0 since position is set
	# after the object is added to stage
	if patrol_starting_position == Vector3(0,0,0):
		patrol_starting_position = global_position

func _process(delta):
	check_for_player_if_not_exist()
	check_for_starting_position()
	
	# State Machine Flow:
	# 1. Each frame, execute behavior based on current state
	# 2. Check conditions for state transitions after executing behavior
	match current_state:
		State.PATROL:
			patrol_movement(delta)
		State.PURSUE:
			pursue_player()
			check_return_to_pursue_or_patrol()  # Check if should transition to RETURN
			check_attack_range()  # Future: Check if close enough to attack
		State.RETURN:
			return_to_patrol()
		State.ATTACK:
			attack_player()  # Future: Implement attack behavior
			check_return_to_pursue_or_patrol()
		
func check_return_to_pursue_or_patrol() -> void:
	# we need to wait a bit anyway before we can attack again
	# so go back to pursuing
	if player_in_line_of_sight:
		current_state = State.PURSUE
	else:
		current_state = State.RETURN

func patrol_movement(delta):
	# Move in the current direction
	velocity = -global_transform.basis.z * patrol_speed
	move_and_slide()
	
	# Keep track of distance traveled for turning
	current_distance += patrol_speed * delta
	
	# Turn after traveling the set distance
	if current_distance >= distance_to_travel:
		await turn()
		current_distance = 0.0

func turn():
	var target_rotation = 0.0
	target_rotation = rotation.y + deg_to_rad(turn_angle)
	
	# Create a tween for smooth rotation
	var turn_duration = 2.0
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", target_rotation, turn_duration)
	
	await tween.finished

func pursue_player():
	if player:
		# Face the player and move towards them
		look_at(player.global_position, Vector3.UP)
		velocity = -global_transform.basis.z * pursuit_speed
		move_and_slide()

func return_to_patrol():
	var direction = patrol_starting_position - global_position
	if direction.length() > 1:
		# Move back to the patrol center
		look_at(patrol_starting_position, Vector3.UP)
		velocity = -global_transform.basis.z * patrol_speed
		move_and_slide()
	else:
		# Once back at patrol center, resume patrolling
		current_state = State.PATROL

func check_attack_range():
	if player and global_position.distance_to(player.global_position) <= attack_range:
		current_state = State.ATTACK

func attack_player():
	simple_ai_shooter.shoot()
