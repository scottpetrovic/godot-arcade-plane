extends Node3D

@onready var plane_gate_manager: Node3D = $PlaneGateManager
@onready var sky_diving_gate_manager: Node3D = $SkyDivingGateManager

var world_sky: PackedScene = load("res://Environment/Sky/examples/Sky.tscn")

func _ready():
	add_child(world_sky.instantiate())
	
	if GameManager.current_vehicle == Constants.VEHICLE.AIRPLANE:
		sky_diving_gate_manager.visible = false
		plane_gate_manager.visible = true
		return

	if GameManager.current_vehicle == Constants.VEHICLE.SKYDIVER:
		sky_diving_gate_manager.visible = true
		plane_gate_manager.visible = false
		return

func are_all_gates_passed():
	
	var unchecked_children: Array[Node]
	
	if plane_gate_manager.visible && sky_diving_gate_manager.visible:
		#print("Both the gate managers are active in aircraft map. This shouldn't happen")
		return
	
	if plane_gate_manager.visible:
		unchecked_children = plane_gate_manager.get_children().filter(func(x): return not x.is_checked)
	elif sky_diving_gate_manager.visible:
		unchecked_children = sky_diving_gate_manager.get_children().filter(func(x): return not x.is_checked)

	# print("Gates left: ", unchecked_children.size())
	return unchecked_children.size() == 0

func is_player_on_landing_pad():
	return $AircraftCarrier/AreaLandingStrip.is_player_on_landing_strip
