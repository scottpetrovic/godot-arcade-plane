extends Node3D

@export var plane: Player
@export var animation_player: AnimationPlayer

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
