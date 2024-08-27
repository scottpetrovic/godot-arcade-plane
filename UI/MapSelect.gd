extends Node3D

@onready var airport_level_button: Button = $Control/CenterContainer/VBoxContainer/AirportLevelButton
@onready var aircraft_carrier_level_button: Button = $Control/CenterContainer/VBoxContainer/AircraftCarrierLevelButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	airport_level_button.pressed.connect(airport_level_click)
	aircraft_carrier_level_button.pressed.connect(aircraft_carrier_level_click)

func airport_level_click():
		GameManager.set_current_map(Constants.MAP.AIRPORT)
		GameManager.go_to_vehicle_selection_screen()

func aircraft_carrier_level_click():
		GameManager.set_current_map(Constants.MAP.AIRCRAFTCARRIER)
		GameManager.go_to_vehicle_selection_screen()
