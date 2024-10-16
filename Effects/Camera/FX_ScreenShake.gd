class_name ScreenShake
extends Node

# Constant screen shake variables
var constant_shake_strength: float = 0.01
var is_constant_shaking: bool = false
var constant_shake_timer: float = 0.0

# Impulse-based screen shake variables
var impulse_shake_strength: float = 0.0
var impulse_shake_duration: float = 0.0
var impulse_shake_timer: float = 0.0

@onready var main_camera: Camera3D = $".."

func _process(delta: float) -> void:
	if is_constant_shaking:
		constant_shake_timer += delta

		var offset = Vector3(
			randf_range(-constant_shake_strength, constant_shake_strength),
			randf_range(-constant_shake_strength, constant_shake_strength),
			0.0
		)
		main_camera.global_transform.origin += offset

	if impulse_shake_duration > 0.0:
		impulse_shake_timer += delta
		
		var offset = Vector3(
			randf_range(-impulse_shake_strength, impulse_shake_strength),
			randf_range(-impulse_shake_strength, impulse_shake_strength),
			0.0
		)
		main_camera.global_transform.origin += offset

		if impulse_shake_timer >= impulse_shake_duration:
			impulse_shake_duration = 0.0
			impulse_shake_timer = 0.0

func start_constant_shake( strength: float) -> void:
	is_constant_shaking = true
	constant_shake_strength = strength

func stop_constant_shake() -> void:
	is_constant_shaking = false

func camera_shake_impulse(strength: float, duration: float) -> void:
	impulse_shake_strength = strength
	impulse_shake_duration = duration
	impulse_shake_timer = 0.0
