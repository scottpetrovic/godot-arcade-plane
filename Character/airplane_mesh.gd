extends Node3D

@export var plane: Player
@export var animation_player: AnimationPlayer

@export var flight_controller: FlightController


var airplane_original_scale: float

func open_landing_gears(value: bool) -> void:
	if value == false:
		animation_player.play("landing_gear_up")
	else:
		animation_player.play_backwards("landing_gear_up")


func _ready() -> void:
	airplane_original_scale = scale.y
	
func _process(delta: float) -> void:
	rotate_propellor(delta)
	update_aileron(delta)
	
	
func update_aileron(delta) -> void:

	var pitch_input: float = flight_controller.pitch_input
	var rotate_input: float = flight_controller.turn_input
	var angle_multiplier: float = 0.6
	
	var left_airleron: MeshInstance3D = get_node("LeftRudder") as MeshInstance3D
	var right_airleron: MeshInstance3D = get_node("RightRudder") as MeshInstance3D

	# if we are turning, use that to update 3d model
	if rotate_input != 0.0:
		if rotate_input < 0.0: # roll right
			left_airleron.rotation.x = rotate_input * angle_multiplier
			right_airleron.rotation.x = -rotate_input * angle_multiplier
		else: # roll left
			left_airleron.rotation.x = rotate_input * angle_multiplier
			right_airleron.rotation.x = -rotate_input * angle_multiplier
		return

	# only changing pitch
	if pitch_input != 0.0:
		left_airleron.rotation.x = -pitch_input * angle_multiplier
		right_airleron.rotation.x = -pitch_input * angle_multiplier
		return


	# not using any input. straighten back out
	left_airleron.rotation.x = 0
	right_airleron.rotation.x = 0



func rotate_propellor(delta: float) -> void:
	# rotate propellor based off forward speed
	var propellor_speed_multiplier: float = 3.0
	var rotate_amount = delta * plane.flight_controller.forward_speed * propellor_speed_multiplier
	get_node("Propellor").rotate( Vector3.FORWARD, rotate_amount)

func squash_and_stretch(delta: float) -> void:
	# a bit of squash and stretch when pitching in the air
	if plane.is_on_floor() == false:
		var scale_pitch_amount_y = airplane_original_scale
		var scale_pitch_amount_x = airplane_original_scale
		if plane.pitch_input != 0.0:
			scale_pitch_amount_y = airplane_original_scale * 0.95
			scale_pitch_amount_x = airplane_original_scale * 1.4
		scale.y = lerp(scale.y, scale_pitch_amount_y, plane.lerp_speed_modifier * delta)
		scale.x = lerp(scale.x, scale_pitch_amount_x, plane.lerp_speed_modifier * delta)
	else:
		scale.y = airplane_original_scale
		scale.x = airplane_original_scale
