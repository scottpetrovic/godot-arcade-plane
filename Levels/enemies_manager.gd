extends Node

@export var enemy_scene: PackedScene  = load("res://Props/EnemyAir/SimpleAirEnemy.tscn")
@export var num_enemies: int = 20

@onready var spawn_area: Area3D = $SpawnArea
@onready var enemies_container: Node = $EnemiesContainer


func _ready():
	spawn_initial_enemies()

func spawn_initial_enemies():
	for i in range(num_enemies):
		spawn_enemy()

func spawn_enemy():
	var enemy_instance = enemy_scene.instantiate()
	
	# Get a random position within the spawn area
	var spawn_position = get_random_position_in_spawn_area()

	# Set a random y-rotation
	enemy_instance.rotation.y = randf_range(0, 2 * PI)
	
	# Add the enemy to the Enemies container
	enemies_container.add_child(enemy_instance)
	
	# Connect the enemy's death signal
	enemy_instance.connect("enemy_died", Callable(self, "_on_enemy_died"))

	enemy_instance.global_transform.origin = spawn_position


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
	# The enemy will remove itself, so we don't need to do it here
	# Spawn a new enemy to replace the one that died
	spawn_enemy()

func get_enemy_count() -> int:
	return enemies_container.get_child_count()
