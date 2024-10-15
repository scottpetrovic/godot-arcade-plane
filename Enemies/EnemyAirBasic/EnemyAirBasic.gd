extends CharacterBody3D

@onready var health_system: HealthSystem = $HealthSystem
@onready var enemy_state_machine: EnemyStateMachine = $EnemyStateMachine

var player: Player
var points_value: int = 1000 # player gets points

signal enemy_died(enemy)

func _ready():
	health_system.death.connect(lost_all_health)
	health_system.set_starting_health(3.0)
	name = "Air Seaman"

func _process(delta: float) -> void:
	check_for_player_if_not_exist()


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
