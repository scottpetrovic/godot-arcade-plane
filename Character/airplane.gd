# Main Player Node (CharacterBody3D)
extends CharacterBody3D

# Child nodes
@onready var flight_controller: Node = $FlightController
@onready var fuel_system: Node = $FuelSystem
@onready var health_system: Node = $HealthSystem
@onready var flight_instruments: Node = $FlightInstruments
@onready var plane_mesh: Node3D = $PlaneMesh
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# for other objects that need to reference us
	GameManager.set_player(self) 

func _physics_process(delta: float) -> void:
	if not flight_controller.enable_movement:
		return
	
	flight_controller.process_flight(delta)
	move_and_slide()

func hit() -> void:
	health_system.take_damage(1.0)

func collided_with_fuel_can() -> void:
	fuel_system.refuel(20)
