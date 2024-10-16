extends Node

@onready var player: Player = $"../../Airplane"
@onready var screen_shake: ScreenShake = $"../ScreenShake"


func _process(delta: float) -> void:
	calculate_speed_screenshake()
	
func calculate_speed_screenshake() -> void:
	var character_throttle: float = player.flight_controller.forward_speed / player.flight_controller.max_flight_speed
	
	if character_throttle > 0.8:
		screen_shake.camera_shake_impulse(0.02, 0.02)
	elif character_throttle > 0.9:
		screen_shake.camera_shake_impulse(0.04, 0.04)
