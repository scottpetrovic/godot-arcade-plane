extends Node3D

@onready var main_camera: Camera3D = $"../Camera"

## Shake the camera with parameters for amount of time and intensity
func camera_shake(time_length: float = 1.5, magnitude: float = 1.0):
	var initial_transform = main_camera.transform 
	var elapsed_time = 0.0

	while elapsed_time < time_length:
		var offset = Vector3(
			randf_range(-magnitude, magnitude),
			randf_range(-magnitude, magnitude),
			0.0
		)

		main_camera.transform.origin = initial_transform.origin + offset
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame

	main_camera.transform = initial_transform
