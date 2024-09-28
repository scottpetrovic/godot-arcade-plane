extends CharacterBody3D

# State Machine: Defines possible states for the enemy aircraft
enum State {PATROL, PURSUE, RETURN, ATTACK}  # Added ATTACK state for future implementation

@export var patrol_speed = 10.0  # Units per second
@export var pursuit_speed = 5.0  # Units per second
@export var turn_angle = 30.0  # Degrees
@export var distance_to_travel = 60.0  # Units
@export var detection_radius = 50.0  # How close the player needs to be to trigger pursuit
@export var return_threshold = 100.0  # Distance to return to patrol
@export var attack_range = 20.0  # How close the enemy needs to be to attack (for future use)
@onready var simple_ai_shooter: Node3D = $SimpleAIShooter



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
	create_explosion()
	# do small screen shake to help with effect
	var main_camera: Camera3D = get_viewport().get_camera_3d()
	
	# strenth, duration
	main_camera.get_node("ScreenShake").camera_shake_impulse(.1, 1.6)
	
	queue_free()  # The enemy removes itself from the scene

func create_explosion() -> void:
	# create particle effects since we blew up
	# instanatiate the effects at the root level since we 
	# are about to delete this object
	var BulletObjectHitParticle = preload("res://Effects/Particles/BulletObjectHitParticle/BulletObjectHitParticle.tscn")
	var instance_explosion = BulletObjectHitParticle.instantiate()
	instance_explosion.lifetime = 1.0
	get_tree().root.add_child(instance_explosion)
	instance_explosion.global_position = self.global_position
	instance_explosion.scale = Vector3(12,12,12)

	# attach sound effect node to explosion instance
	var audio_player: AudioStreamPlayer3D = instance_explosion.get_node("AudioNode")
	audio_player.stream = preload("res://Assets/SoundFX/explosion.mp3")
	audio_player.volume_db = 10.0 # make it louder
	audio_player.play()

func _ready():

	if is_instance_valid(player) == false:
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
			check_attack_range()  # Future: Check if close enough to attack
		State.RETURN:
			return_to_patrol()
		State.ATTACK:
			attack_player()  # Future: Implement attack behavior
			check_return_to_pursue()
		
func check_return_to_pursue() -> void:
	# we need to wait a bit anyway before we can attack again
	# so just return to pursue
	current_state = State.PURSUE

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

func check_attack_range():
	if player and global_position.distance_to(player.global_position) <= attack_range:
		current_state = State.ATTACK

func attack_player():
	simple_ai_shooter.shoot()
