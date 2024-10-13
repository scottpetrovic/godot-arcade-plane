extends Marker3D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 45.0

@onready var timer = $SpawnTimer

func _ready():
	# Set up the timer
	timer.wait_time = spawn_interval
	timer.connect("timeout", Callable(self, "_on_SpawnTimer_timeout"))
	timer.start()

func _on_SpawnTimer_timeout():
	spawn_enemy()

func spawn_enemy():
	if enemy_scene:
		var enemy = enemy_scene.instantiate()
		enemy.global_transform.origin = global_transform.origin
		
		# Add the enemy to the scene
		get_tree().current_scene.add_child(enemy)
		print("Enemy spawned at: ", enemy.global_transform.origin)
