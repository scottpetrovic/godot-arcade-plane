class_name BaseEnemy
extends CharacterBody3D

@onready var health_system: HealthSystem

@export var starting_health: float = 3.0 # overrride in inspector
@export var points_value: int = 300 # override in inspector
@export var enemy_name = "Base Enemy" # override in inspector
@export var is_enemy_air_type: bool = true

var player: Player

signal enemy_died(enemy)

func _ready():
	# configure health system for managing health
	health_system = HealthSystem.new()
	add_child(health_system)
	health_system.death.connect(lost_all_health)
	health_system.set_starting_health(starting_health)
	
	# set default name for enemy type
	name = enemy_name

func _process(delta: float) -> void:
	check_for_player_if_not_exist()


func hit() -> void:
	health_system.take_damage(1.0)


func lost_all_health():
	GameManager.add_destruction_points(points_value)
	ObjectSpawner.create_explosion(self.global_position)
	
	if is_enemy_air_type:
		ObjectSpawner.create_crater(self.global_position)
	
	GameManager.current_level_remaining_enemies -= 1
	
	# 10% chance a fuel can will be dropped
	if randf() <= 0.10:
		ObjectSpawner.create_fuel_can(self.global_position)
		
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
