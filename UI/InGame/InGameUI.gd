extends Control

var full_speed_line_density = 0.3 # artistic value

func turn_on_speed_lines():
	$SpeedLinesCameraEffect.material.set_shader_parameter("line_density", full_speed_line_density)
	
func turn_off_speed_lines():
	$SpeedLinesCameraEffect.material.set_shader_parameter("line_density", 0.0)

func show_speedometer(show: bool) -> void:
	$HUD/SpeedometerBackground.visible = show

func _process(delta: float) -> void:
	update_points_value_display()

func update_points_value_display() -> void:
	$HUD/PointsLabel.text = str(GameManager.get_destruction_points()).pad_zeros(10)
