extends CharacterBody3D

@onready var health_system: HealthSystem = $HealthSystem

# State Machine: Defines possible states for the enemy aircraft
enum State {PATROL, PURSUE, RETURN, ATTACK}  # Added ATTACK state for future implementation

@export var patrol_speed = 6.0  # Units per second
@export var pursuit_speed = 8.0  # Units per second
@export var turn_angle = 30.0  # Degrees
@export var distance_to_travel = 60.0  # Units
@export var attack_range = 25.0  # How close the enemy needs to be to attack (for future use)
@onready var simple_ai_shooter: Node = $SimpleAIShooter
@onready var line_of_sight: EnemyLineOfSight = $LineOfSight

var current_distance = 0.0
var current_state = State.PATROL
var player: Player
var patrol_starting_position: Vector3 = Vector3.ZERO
var player_in_line_of_sight: bool = false

var points_value: int = 1000 # player gets points

signal enemy_died(enemy)

func _ready():
	health_system.death.connect(lost_all_health)
	health_system.set_starting_health(3.0)

	line_of_sight.found_player_visuals.connect(_spotted_player)
	line_of_sight.lost_player_visuals.connect(_lost_player)


	name = "Air Seaman"
	
func _spotted_player() -> void:
	print('spotted player visuals', player_in_line_of_sight)
	player_in_line_of_sight = true

	
func _lost_player() -> void:
	player_in_line_of_sight = false


func hit() -> void:
	health_system.take_damage(1.0)

func lost_all_health():
	emit_signal("enemy_died", self) # tell enemy manager
	GameManager.add_destruction_points(points_value)
	GameManager.create_explosion(self.global_position)
	
	# 10% chance a fuel can will be dropped
	if randf() <= 0.10:
		GameManager.create_fuel_can(self.global_position)
		
	# do small screen shake to help with effect
	# strength, duration	
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player < 25:
		var main_camera: Camera3D = get_viewport().get_camera_3d()
		main_camera.get_node("ScreenShake").camera_shake_impulse(.1, 1.6)
	
	queue_free()  # The enemy removes itself from the scene


func check_for_player_if_not_exist():
	if is_instance_valid(player) == false:
		player = GameManager.get_player()

func initialize_starting_position_if_not_done():
	# intialize patrol position for when the 
	# enemy needs to return. Doing this in ready() 
	# seems to start as 0,0,0 since position is set
	# after the object is added to stage
	if patrol_starting_position == Vector3(0,0,0):
		patrol_starting_position = global_position

func _process(delta):
	check_for_player_if_not_exist()
	initialize_starting_position_if_not_done()
	
	# State Machine Flow:
	# 1. Each frame, execute behavior based on current state
	# 2. Check conditions for state transitions after executing behavior
	#print(current_state)
	match current_state:
		State.PATROL:
			patrol_movement(delta)
			check_if_player_is_seen() # PURSUE if we see player
		State.PURSUE:
			pursue_player()
			check_if_lost_player_visuals()  # RETURN back to patrol if we lost player
			check_if_we_can_attack()  # ATTACK player if we are close enough
		State.RETURN:
			return_to_patrol()
			check_if_player_is_seen() # PURSUE if we see player on our return
		State.ATTACK:
			pursue_player()
			attack_player()
			check_if_we_are_out_of_shooting_range() # PURSUE is we are out of attacking range

func check_if_player_is_seen():
	if player_in_line_of_sight:
		current_state = State.PURSUE

func check_if_we_are_out_of_shooting_range():
	if player and global_position.distance_to(player.global_position) > attack_range:
		current_state = State.PURSUE

func check_if_lost_player_visuals():
	if player_in_line_of_sight == false:
		current_state = State.RETURN

func check_if_we_can_attack():
	if player and global_position.distance_to(player.global_position) <= attack_range:
		current_state = State.ATTACK

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



func attack_player():
	simple_ai_shooter.shoot()
