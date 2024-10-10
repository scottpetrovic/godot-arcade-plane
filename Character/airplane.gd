# Main Player Node (CharacterBody3D)
class_name Player
extends CharacterBody3D

# Child nodes
@onready var flight_controller: FlightController = $FlightController
@onready var ground_controller: GroundController = $GroundController
@onready var fuel_system: FuelSystem = $FuelSystem
@onready var health_system: HealthSystem = $HealthSystem
@onready var flight_instruments: FlightInstruments = $FlightInstruments
@onready var plane_mesh: Node3D = $PlaneMesh
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	GameManager.set_player(self)  # for other objects that need to reference us

func _physics_process(delta: float) -> void:
	if not flight_controller.enable_movement:
		return
	
	flight_controller.process_flight(delta)
	
	# add additional logic for movement if we are on ground
	if is_on_floor():
		ground_controller.process_ground_movement(delta)
	else:
		ground_controller.stop_ground_movement()
	
	move_and_slide()

func hit() -> void:
	health_system.take_damage(1.0)
	
func float_on_water() -> void:
	global_position.y = 0 # move to water height
	animation_player.play("water_float")
	
	# stop propellor by changing speed
	flight_controller.forward_speed = 0
	flight_controller.target_speed = 0

func get_wheel_location(type: String) -> Vector3:
	match type:
		"BACK":
			return (plane_mesh.get_node("Landing_Gear_Back") as Node3D).global_position
		"LEFT":
			return (plane_mesh.get_node("Landing_Gear_Left") as Node3D).global_position
		"RIGHT":
			return (plane_mesh.get_node("Landing_Gear_Right") as Node3D).global_position

	return Vector3(0,0,0)
