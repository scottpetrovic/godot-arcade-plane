extends CharacterBody3D
signal enemy_died(enemy)

@onready var line_of_sight: Area3D = $LineOfSight
@onready var ai_shooter: Node = $AIShooter


var _player_reference: Node3D
var turrent_follow_player: bool = false
var attack_range = 25.0  # How close the enemy needs to be to attack (for future use)
var health = 8

# blender uses diferent xyz directions than Godot
# this is needed when doing look at to point things at right direction
# 90 degrees converted to radians
var blender_to_godot_adjustment := deg_to_rad(90) 


func _ready() -> void:
	line_of_sight.body_entered.connect(_body_entered)
	line_of_sight.body_exited.connect(_body_exited)

func _body_entered(_body: Node3D) -> void:
	if _body.name == "Airplane":
		turrent_follow_player = true

func attack_when_ready():
	
	if  is_instance_valid(_player_reference) == false:
		return
		
	var in_attack_range: bool = global_position.distance_to(_player_reference.global_position) <= attack_range
	if in_attack_range:
		ai_shooter.shoot()


func _process(delta: float) -> void:
	
	# make sure we have player reference before potentially acting on it
	if is_instance_valid(_player_reference) == false:
		check_for_player()
		return
	
	if turrent_follow_player:
		gun_follow_player()
		attack_when_ready()


func check_for_player() -> void:
	_player_reference = GameManager.get_player()

func gun_follow_player() -> void:
	var gun: MeshInstance3D = $ShipMesh/Gun
	gun.look_at(_player_reference.global_position)
	gun.rotate_object_local(Vector3.RIGHT, blender_to_godot_adjustment)

func _body_exited(_body: Node3D) -> void:
	if _body.name == "Airplane":
		turrent_follow_player = false

func hit() -> void:
	health -= 1
	
	if health <= 0:
		die()

func die():
	emit_signal("enemy_died", self)
	GameManager.create_explosion(self.global_position, 30)
	# do small screen shake to help with effect
	# strenth, duration
	var main_camera: Camera3D = get_viewport().get_camera_3d()
	main_camera.get_node("ScreenShake").camera_shake_impulse(.1, 1.6)
	
	queue_free()  # The enemy removes itself from the scene
