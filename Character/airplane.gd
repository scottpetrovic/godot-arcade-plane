# Main Player Node (CharacterBody3D)
class_name Player
extends CharacterBody3D

# Child nodes
@onready var flight_controller: FlightController = $FlightController
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
	move_and_slide()

func hit() -> void:
	health_system.take_damage(1.0)
