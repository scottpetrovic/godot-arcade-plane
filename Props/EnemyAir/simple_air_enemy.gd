extends CharacterBody3D

# State Machine: Defines possible states for the enemy aircraft
enum State {PATROL, PURSUE, RETURN, ATTACK}  # Added ATTACK state for future implementation

@export var patrol_speed = 10.0  # Units per second
@export var pursuit_speed = 5.0  # Units per second
@export var turn_angle = 60.0  # Degrees
@export var distance_to_travel = 10.0  # Units
@export var detection_radius = 50.0  # How close the player needs to be to trigger pursuit
@export var return_threshold = 100.0  # Distance to return to patrol
@export var attack_range = 20.0  # How close the enemy needs to be to attack (for future use)

var current_distance = 0.0
var current_state = State.PATROL
var player: Node3D = null
var patrol_starting_position: Vector3 = Vector3.ZERO

signal enemy_died(enemy)

var health = 2

func hit() -> void:
	health -= 1
	
	if health <= 0:
		die()

func die():
	emit_signal("enemy_died", self)
	self.hide() # hack until I can fix weird null check in radar
	# queue_free()  # The enemy removes itself from the scene

func _ready():

	if player == null:
		player = GameManager.get_player()
		return
	
	patrol_starting_position = global_position


func _process(delta):
	# State Machine Flow:
	# 1. Each frame, execute behavior based on current state
	# 2. Check conditions for state transitions after executing behavior
	match current_state:
		State.PATROL:
			patrol_movement(delta)
			check_player_proximity()  # Check if should transition to PURSUE
		State.PURSUE:
			pursue_player()
			check_return_to_patrol()  # Check if should transition to RETURN
			# check_attack_range()  # Future: Check if close enough to attack
		State.RETURN:
			return_to_patrol()
		# State.ATTACK:
		#     attack_player()  # Future: Implement attack behavior
		#     check_attack_finished()  # Future: Check if should return to PURSUE

func patrol_movement(delta):
	# Move in the current direction
	velocity = -global_transform.basis.z * patrol_speed
	move_and_slide()
	
	# Keep track of distance traveled for turning
	current_distance += patrol_speed * delta
	
	# Turn after traveling the set distance
	if current_distance >= distance_to_travel:
		turn()
		current_distance = 0.0

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

func turn():
	# Perform the turn for the patrol pattern
	rotate_y(deg_to_rad(turn_angle))

func check_player_proximity():
	# Transition to PURSUE if player is within detection radius
	if player and global_position.distance_to(player.global_position) <= detection_radius:
		current_state = State.PURSUE

func check_return_to_patrol():
	# Transition to RETURN if player is beyond return threshold
	if player and global_position.distance_to(player.global_position) > return_threshold:
		current_state = State.RETURN

# Pseudo-code for future attack behavior:

# func check_attack_range():
#     if player and global_position.distance_to(player.global_position) <= attack_range:
#         current_state = State.ATTACK

# func attack_player():
#     # Implement attack logic here
#     # This could involve firing projectiles, charging at the player, etc.
#     pass

# func check_attack_finished():
#     # Determine if the attack is complete
#     # This could be based on a timer, ammo depletion, etc.
#     # if attack_is_finished:
#     #     current_state = State.PURSUE
