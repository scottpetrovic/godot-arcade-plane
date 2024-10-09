# Enemies that mostly just stay in the same place
# because of this, they don't need a full state machine
class_name BasicStationaryEnemyMovement
extends Node

signal enemy_died(enemy)
@onready var simple_ai_shooter: Node = $"../SimpleAIShooter"
@onready var enemy_reference: BaseEnemy = $".."
@onready var gun: MeshInstance3D = $"../ShipMesh/Gun"
var _player_reference: Node3D


func attack_when_ready():
	
	var in_attack_range: bool = enemy_reference.global_position.distance_to(_player_reference.global_position) <= simple_ai_shooter.attack_range
	if in_attack_range:
		simple_ai_shooter.shoot()

func check_for_player_if_not_exist():
	if is_instance_valid(_player_reference) == false:
		_player_reference = GameManager.get_player()

func _process(delta: float) -> void:
	
	check_for_player_if_not_exist()	

	# make sure we have player reference before potentially acting on it
	if is_instance_valid(_player_reference) == false:
		_player_reference = GameManager.get_player()
		return
	
	gun_follow_player()
	attack_when_ready()

func gun_follow_player() -> void:
	
	# blender uses diferent xyz directions than Godot
	# this is needed when doing look at to point things at right direction
	# 90 degrees converted to radians
	var blender_to_godot_adjustment := deg_to_rad(90) 


	gun.look_at(_player_reference.global_position)
	gun.rotate_object_local(Vector3.RIGHT, blender_to_godot_adjustment)
