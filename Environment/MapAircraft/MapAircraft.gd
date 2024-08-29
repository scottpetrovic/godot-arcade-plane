extends Node3D

@onready var plane_gate_manager: Node3D = $PlaneGateManager
@onready var sky_diving_gate_manager: Node3D = $SkyDivingGateManager
@onready var sky_diving_landing_target: Node3D = $SkydivingLandingTarget

var world_sky: PackedScene = load("res://Environment/Sky/examples/Sky.tscn")

func skydiver_starting_position() -> Vector3:
	return $SkydiverStartingPosition.global_position

func _ready():
	add_child(world_sky.instantiate())
	
	if GameManager.current_vehicle == Constants.VEHICLE.AIRPLANE:
		sky_diving_gate_manager.visible = false
		plane_gate_manager.visible = true
		# hides it. visible = false doesn't disable colliders, so this works
		sky_diving_landing_target.global_position = Vector3(0,-100,0) 
		return

	if GameManager.current_vehicle == Constants.VEHICLE.SKYDIVER:
		sky_diving_gate_manager.visible = true
		plane_gate_manager.visible = false
		sky_diving_landing_target.visible = true
		return

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

func is_player_on_landing_pad():
	return $AircraftCarrier/Runway.is_player_on_landing_strip

func percentage_of_all_gates_passed() -> float:
	var total_gates: int = 0
	var gates_complete: int = 0 
	
	if plane_gate_manager.visible:
		total_gates = plane_gate_manager.get_children().size()
		gates_complete = plane_gate_manager.get_children().filter(func(x): return x.is_checked).size()
	elif sky_diving_gate_manager.visible:
		total_gates = sky_diving_gate_manager.get_children().size()
		gates_complete = sky_diving_gate_manager.get_children().filter(func(x): return x.is_checked).size()

	return float(gates_complete) / float(total_gates)
