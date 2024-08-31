extends Node3D

@onready var airplane_button: Button = $Control/CenterContainer/VBoxContainer/GridContainer/AirplaneButton
@onready var skydiving_button: Button = $Control/CenterContainer/VBoxContainer/GridContainer/SkydivingButton



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	airplane_button.pressed.connect(airplane_vehicle_selected)
	skydiving_button.pressed.connect(skydiving_vehicle_selected)

func airplane_vehicle_selected():
	GameManager.set_current_vehicle(Constants.VEHICLE.AIRPLANE)
	GameManager.go_to_next_level()

func skydiving_vehicle_selected():
	GameManager.set_current_vehicle(Constants.VEHICLE.SKYDIVER)
	GameManager.go_to_next_level()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
