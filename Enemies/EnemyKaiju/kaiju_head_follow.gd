extends Node


@onready var head: MeshInstance3D = $"../kaiju-puppet/body_base/head"
@onready var kaiju: AnimatableBody3D = $".."
@onready var line_of_sight: EnemyLineOfSight = $"../kaiju-puppet/body_base/LineOfSight"


var _player_reference: Node3D
var can_see_player: bool = false # helps us know when we can look at player

var initial_head_rotation: Vector3
var tween: Tween

# blender uses diferent xyz directions than Godot
# this is needed when doing look at to point things at right direction
# it is assumed that the object is facing forward in Blender for this to work
# this is a different solution than if the object is facing up like turret
# -180 degrees converted to radians
var blender_to_godot_forward_adjustment := deg_to_rad(-180) 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	initial_head_rotation = head.rotation
	
	line_of_sight.found_player_visuals.connect(_see_player_visuals)
	line_of_sight.lost_player_visuals.connect(_lost_player_visuals)


func _see_player_visuals() -> void:
	can_see_player = true
	
func _lost_player_visuals() -> void:
	can_see_player = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# make sure we have player reference before potentially acting on it
	if is_instance_valid(_player_reference) == false:
		_player_reference = GameManager.get_player()
		return
		
	if can_see_player:
		smooth_head_follow_player(delta)
		#head_follow_player()
	else:
		reset_head_position()


func smooth_head_follow_player(delta: float) -> void:
	var head_rotation_speed: float = 2.0  # Adjust this to control rotation speed
	var head_rotation_smoothness: float = 5.0  # Adjust this to control smoothness
	var target_position = _player_reference.global_position
	var desired_transform = head.global_transform.looking_at(target_position, Vector3.UP)
	desired_transform = desired_transform.rotated_local(Vector3.UP, blender_to_godot_forward_adjustment)
	
	# Interpolate current rotation to desired rotation
	var current_basis = head.global_transform.basis
	var target_basis = desired_transform.basis
	var interpolated_basis = current_basis.slerp(target_basis, delta * head_rotation_speed)
	
	head.global_transform = Transform3D(interpolated_basis, head.global_position)
	
func head_follow_player() -> void:
	head.look_at(_player_reference.global_position)
	head.rotate_object_local(Vector3.UP, blender_to_godot_forward_adjustment)
	
func reset_head_position() -> void:
	var reset_rotation_time: float = 1.0
	tween = create_tween()
	tween.tween_property(head, "rotation", initial_head_rotation, reset_rotation_time)
