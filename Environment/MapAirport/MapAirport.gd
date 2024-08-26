extends Node3D

@onready var plane_gate_manager: Node3D = $PlaneGateManager
@onready var sky_diving_gate_manager: Node3D = $SkyDivingGateManager

func level_set():
	if GameManager.current_vehicle == 'Plane':
		sky_diving_gate_manager.visible = false
		plane_gate_manager.visible = true

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
