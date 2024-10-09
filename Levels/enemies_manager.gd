extends Node

@export var simple_air_enemy: PackedScene  = load("res://Enemies/EnemyAir/SimpleAirEnemy.tscn")
@export var num_air_simple_enemies: int = 3

@export var simple_sea_enemy: PackedScene  = load("res://Enemies/EnemySeaTurretShip/enemy_turret_ship.tscn")
@export var num_simple_sea_enemies: int = 3

@export var simple_air_scout_enemy: PackedScene  = load("res://Enemies/EnemyAirScout/EnemyAirScout.tscn")
@export var num_air_simple_scout_enemies: int = 3

@onready var spawn_area: Area3D = $SpawnArea
@onready var enemies_container: Node = $EnemiesContainer

func _ready():
	spawn_initial_enemies()
	GameManager.current_level_remaining_enemies = get_enemy_count()

func spawn_initial_enemies():
	for i in range(num_air_simple_enemies):
		spawn_enemy(simple_air_enemy, false)
		
	for i in range(num_simple_sea_enemies):
		spawn_enemy(simple_sea_enemy, true)
		
	for i in range(num_air_simple_scout_enemies):
		spawn_enemy(simple_air_scout_enemy, false)
	

func spawn_enemy(enemy_scene: PackedScene, place_on_floor: bool):
	var enemy_instance = enemy_scene.instantiate()
	
	# Get a random position within the spawn area
	var spawn_position = get_random_position_in_spawn_area()
	# Add the enemy to the Enemies container
	enemies_container.add_child(enemy_instance)
	enemy_instance.connect("enemy_died", Callable(self, "_on_enemy_died"))
	
	# Set a random y-rotation
	enemy_instance.rotation.y = randf_range(0, 2 * PI)
	enemy_instance.global_transform.origin = spawn_position
	
	if place_on_floor:
		enemy_instance.global_position.y = 0


func get_random_position_in_spawn_area() -> Vector3:
	var spawn_collision_shape = spawn_area.get_node("CollisionShape3D")
	if spawn_collision_shape:
		var shape = spawn_collision_shape.shape
		if shape is BoxShape3D:
			var extents = shape.extents
			var x = randf_range(-extents.x, extents.x)
			var y = randf_range(-extents.y, extents.y)
			var z = randf_range(-extents.z, extents.z)
			return spawn_area.global_transform * Vector3(x, y, z)
	
	# Fallback to a default position if something goes wrong
	push_warning("Couldn't get a valid position from SpawnArea, using default")
	return Vector3.ZERO

func _on_enemy_died(enemy):
	
	# the enemy count is calculated by looking at the tree
	# it might take a few process calls before the enemy is 
	# actually removed from the scene tree
	await get_tree().create_timer(0.5).timeout
	
	# The enemy will remove itself, so we don't need to do it here
	# Spawn a new enemy to replace the one that died
	GameManager.current_level_remaining_enemies = get_enemy_count()
	if get_enemy_count() == 0:
		EventBus.emit_signal("all_objectives_complete")

func get_enemy_count() -> int:
	return enemies_container.get_child_count()
