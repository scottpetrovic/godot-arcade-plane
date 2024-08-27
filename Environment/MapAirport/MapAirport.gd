extends Node3D

@onready var plane_gate_manager: Node3D = $PlaneGateManager
@onready var sky_diving_gate_manager: Node3D = $SkyDivingGateManager
@onready var ground_plane: StaticBody3D = $GroundPlane

var world_sky_hack: PackedScene = load("res://Environment/Sky/examples/Sky.tscn")

func _ready():
	# hack to prevent weird C++ leak that happens when changing scene
	# the world environment breaks if I just put it on the scene
	add_child(world_sky_hack.instantiate())
	
	if GameManager.current_vehicle == 'Plane':
		sky_diving_gate_manager.visible = false
		plane_gate_manager.visible = true
		return
	
	if GameManager.current_vehicle == "Skydiving":
		sky_diving_gate_manager.visible = true
		plane_gate_manager.visible = false
		return

func has_player_crashed_into_ground():
	return $GroundPlane.has_crashed_on_ground

func is_player_on_landing_pad(): 
	return $Airport/AreaLandingStrip.is_player_on_landing_strip

func get_plane_starting_transform_1() -> Node3D:
	return $StartPositions/Plane1

func are_all_gates_passed():
	
	var unchecked_children: Array[Node]
	
	if plane_gate_manager.visible && sky_diving_gate_manager.visible:
		print("Both the gate managers are active in aircraft map. This shouldn't happen")
		return
	
	if plane_gate_manager.visible:
		unchecked_children = plane_gate_manager.get_children().filter(func(x): return not x.is_checked)
	elif sky_diving_gate_manager.visible:
		unchecked_children = sky_diving_gate_manager.get_children().filter(func(x): return not x.is_checked)

	# print("Gates left: ", unchecked_children.size())
	return unchecked_children.size() == 0
