extends CharacterBody3D

@onready var turret_manager: Node3D = $TurretManager
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@onready var simple_patrol_movement: SimplePatrolMovement = $SimplePatrolMovement
@onready var enemy_crash_movement: Node = $EnemyCrashMovement

var points_value: int = 300 # override in inspector
var player: Player
var has_stalled: bool = false

signal enemy_died(enemy)

func _process(delta: float) -> void:
	check_for_player_if_not_exist()
	
	if has_stalled && enemy_crash_movement.check_if_crashed_into_ground():
		die()
	
	if check_if_all_turrets_destroyed():
		enemy_crash_movement.crash_towards_ground()
		has_stalled = true
	else:
		simple_patrol_movement.patrol_movement(delta)

		
func die() -> void:
	emit_signal("enemy_died", self) # tell enemy manager
	GameManager.add_destruction_points(points_value)
	GameManager.current_level_remaining_enemies -= 1
	create_three_bb_explosions()
	
	# do small screen shake to help with effect
	# strength, duration	
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player < 25:
		var main_camera: Camera3D = get_viewport().get_camera_3d()
		main_camera.get_node("ScreenShake").camera_shake_impulse(.1, 1.6)
	
	queue_free()  # The enemy removes itself from the scene
	
func check_if_all_turrets_destroyed():
	if turret_manager.get_children().size() == 0:
		return true

	return false
	
func create_three_bb_explosions() -> void:
	# Get the bounding box of the enemy
	var aabb = collision_shape_3d.shape.get_debug_mesh().get_aabb()
	
	# Calculate three positions for explosions
	var explosion_positions = [
		global_position + Vector3(aabb.size.x / 2, 0, 0),  # right
		global_position + Vector3(-aabb.size.x / 2, 0, 0), # left
		global_position + Vector3(0, aabb.size.y / 2, 0)   # top
	]
	
	# Create explosions at all positions simultaneously
	for position in explosion_positions:
		GameManager.create_explosion(position)

func check_for_player_if_not_exist():
	if is_instance_valid(player) == false:
		player = GameManager.get_player()
