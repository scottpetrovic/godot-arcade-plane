class_name BasicFlyingEnemyMovement
extends Node

@onready var enemy_state_machine: EnemyStateMachine = $"../EnemyStateMachine"
@onready var enemy: CharacterBody3D = $".."
@onready var simple_ai_shooter: Node = $"../SimpleAIShooter"
@onready var enemy_stall_logic: Node = $"../EnemyStallLogic"


@export var patrol_speed = 6.0  # Units per second
@export var pursuit_speed = 8.0  # Units per second
@export var distance_to_travel = 60.0  # Units

var player: Player
var patrol_starting_position: Vector3 = Vector3.ZERO
var current_distance = 0.0
var turn_angle = 0.0  # Degrees

func _ready() -> void:
	
	# every patrol will be a circle, but this randomized how big the
	# circle will be a bit
	var possible_angles: Array[float] = [20.0, -20.0, 30.0, -30.0, 45.0, -45.0]
	turn_angle = possible_angles[randi() % possible_angles.size()]


func check_for_player_if_not_exist():
	if is_instance_valid(player) == false:
		player = GameManager.get_player()

func _process(delta: float) -> void:

	check_for_player_if_not_exist()
	initialize_starting_position_if_not_done()

	# controls enemy physical movement related to state machine
	match enemy_state_machine.current_state:
			enemy_state_machine.State.PATROL:
				patrol_movement(delta)
			enemy_state_machine.State.STALL:
				enemy_stall_logic.crash_towards_ground()
			enemy_state_machine.State.PURSUE:
				pursue_player()
			enemy_state_machine.State.RETURN:
				return_to_patrol()
			enemy_state_machine.State.ATTACK:
				pursue_player()
				simple_ai_shooter.shoot()


func initialize_starting_position_if_not_done():
	# intialize patrol position for when the 
	# enemy needs to return. Doing this in ready() 
	# seems to start as 0,0,0 since position is set
	# after the object is added to stage
	if patrol_starting_position == Vector3(0,0,0):
		patrol_starting_position = enemy.global_position

func patrol_movement(delta):
	# Move in the current direction
	enemy.velocity = -enemy.global_transform.basis.z * patrol_speed
	enemy.move_and_slide()
	
	# Keep track of distance traveled for turning
	current_distance += patrol_speed * delta
	
	# Turn after traveling the set distance
	if current_distance >= distance_to_travel:
		await turn()
		current_distance = 0.0

func turn():
	var target_rotation = 0.0
	target_rotation = enemy.rotation.y + deg_to_rad(turn_angle)
	
	# Create a tween for smooth rotation
	var turn_duration = 2.0
	var tween = create_tween()
	tween.tween_property(enemy, "rotation:y", target_rotation, turn_duration)
	
	await tween.finished

func pursue_player():
	if player:
		# Face the player and move towards them
		enemy.look_at(player.global_position, Vector3.UP)
		enemy.velocity = -enemy.global_transform.basis.z * pursuit_speed
		enemy.move_and_slide()

func return_to_patrol():
	# Move back to the patrol center
	enemy.look_at(patrol_starting_position, Vector3.UP) # align enemy
	enemy.velocity = -enemy.global_transform.basis.z * patrol_speed
	enemy.move_and_slide()
