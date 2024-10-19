extends Node

var _player_reference: Node3D
@onready var head: MeshInstance3D = $"../kaiju-puppet/body_base/head"

# blender uses diferent xyz directions than Godot
# this is needed when doing look at to point things at right direction
# 90 degrees converted to radians
var blender_to_godot_adjustment := deg_to_rad(-180) 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# make sure we have player reference before potentially acting on it
	if is_instance_valid(_player_reference) == false:
		_player_reference = GameManager.get_player()
		return
		
	head_follow_player()
	
func head_follow_player() -> void:
	head.look_at(_player_reference.global_position)
	head.rotate_object_local(Vector3.UP, blender_to_godot_adjustment)
