extends Node3D

var is_player_on_landing_strip: bool = false

func _ready() -> void:
	$AreaLandingStrip.body_entered.connect(_body_entered)
	$AreaLandingStrip.body_exited.connect(_body_exited)

func _body_entered(body: Node3D):
	
	if body.name == 'Airplane':
		is_player_on_landing_strip = true
		var plane_current_speed: float = (body as Player).flight_controller.forward_speed
		var plane_landing_angle =  (body as Player).flight_instruments.calculate_level_angle()
		
		# if we landed and we are at over a 90 degree angle, we crashed
		# cannot land upside or at a 90 degreee angle
		if plane_landing_angle > 45:
			EventBus.emit_signal("player_crashed", "ground")
		
		if plane_current_speed > 1.4:
			# landing angle used for scoring with how straight we are
			# if we are under 3 degrees from perfect. just give player a perfect score
			var landing_score = 100 - (plane_landing_angle * 2)
			if plane_landing_angle < 3:
				landing_score = 11
			GameManager.current_level_landing_score = landing_score


func _body_exited(body: Node3D):
	if body.name == 'Airplane':
		is_player_on_landing_strip = false
