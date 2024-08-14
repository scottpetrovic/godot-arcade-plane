extends Camera3D

var time_passed: float = 0.0
var oscillation_speed: float = 0.1  # Speed of the oscillation
var oscillation_amplitude: float = 0.1  # Amplitude of the oscillation
var initial_position: Vector3  # To store the initial position of the camera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_position = transform.origin

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_passed += delta
	var new_y_position = initial_position.y + oscillation_amplitude * sin(time_passed * oscillation_speed)
	var new_transform = transform
	new_transform.origin.y = new_y_position
	transform = new_transform
