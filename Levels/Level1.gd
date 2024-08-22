extends Node3D

@onready var gates: Node = $Gates
@onready var aircraft_carrier: Node3D = $AircraftCarrier
@onready var airplane: CharacterBody3D = $Airplane

var gates_completed_message_shown: bool = false

@onready var checkpoints_passed_overlay: CenterContainer = $UI/CheckpointsPassedOverlay
@onready var training_complete_overlay: CenterContainer = $UI/TrainingCompleteOverlay
@onready var player_crashed_overlay: CenterContainer = $UI/PlayerCrashedOverlay

# HUD display items to always show
@onready var speed_label: Label = $UI/HUD/SpeedLabel
@onready var altitude_label: Label = $UI/HUD/AltitudeLabel
@onready var time_label: Label = $UI/HUD/TimeLabel
@onready var speed_indicator: ColorRect = $UI/HUD/TextureRect/Speedindicator


var elapsed_time: float = 0.0

var splash: PackedScene = load("res://Ocean/SplashParticles.tscn")

func is_mission_complete() -> bool:
	# all gates are passed
	# airplane is currently on landing strip
	# airplane has come to a stop
	if aircraft_carrier.is_player_on_landing_strip && are_all_gates_passed():
		if airplane.forward_speed < 0.01:
			return true
	return false


func update_hud(delta: float):

	var altitude_multiplier = 5.0 # magic number that looks better on UI
	var speed_multiplier = 20.0 # magic number that looks better on UI
	speed_label.text = str(int(airplane.forward_speed * speed_multiplier))

	var altitude_string = str(int(airplane.global_transform.origin.y * altitude_multiplier))
	altitude_label.text = altitude_string.pad_zeros(5)
	
	elapsed_time += delta
	time_label.text = format_elapsed_time(elapsed_time)

	update_speed_indicator()
	
func update_speed_indicator():
	
	# find out min and max for speed indicator
	# 0 degrees is facing straight up
	var min_angle_for_indicator = -83
	var max_angle_for_indicator = 83
	var total_angle_values = abs(min_angle_for_indicator) + abs(max_angle_for_indicator)
	
	# create ratio to help map angle facing and current speed
	var speed_indicator_multiplier = 13.7 # magic number
	var conversion_ratio: float = (airplane.max_flight_speed * speed_indicator_multiplier) / total_angle_values
	speed_indicator.rotation_degrees = min_angle_for_indicator + (airplane.forward_speed*speed_indicator_multiplier*conversion_ratio)

# move this to a utility function
func format_elapsed_time(elapsed: float) -> String:
	var minutes = int(elapsed) / 60
	var seconds = int(elapsed) % 60
	return str(minutes) + ":" + str(seconds).pad_zeros(2)


func plane_camera_screenshake():
	
	# if plane is going 90% speed or more, do a constant screen shake to show speed
	if (airplane.forward_speed / airplane.max_flight_speed) > .9:
		$Camera/ScreenShake.start_constant_shake(0.02)
	else:
		$Camera/ScreenShake.stop_constant_shake()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# stop updating UI when we are complete
	# this also upates time mission is taking
	if is_mission_complete() == false:
		update_hud(delta)
		
	plane_camera_screenshake()
	
	# maybe show this on the UI somewhere?
	if are_all_gates_passed() && gates_completed_message_shown == false:
		gates_completed_message_shown = true
		# show the UI to land for a couple seconds
		checkpoints_passed_overlay.visible = true
		await get_tree().create_timer(2.0).timeout
		checkpoints_passed_overlay.visible = false

	if is_mission_complete():
		goal_completed()

func goal_completed():
	# make sure to only call this one time
	if training_complete_overlay.visible == false:
		airplane.turn_engine_off()
		training_complete_overlay.visible = true
		await get_tree().create_timer(4.0).timeout
		SceneTransition.change_scene("res://MissionEndOverview/MissionEndOverview.tscn")
		# TODO: Controls for controller
		# TODO: export to HTML5
		# TODO: pause screen
		# TODO: controls if on mobile

func are_all_gates_passed():
	var unchecked_children = gates.get_children().filter(func(x): return not x.is_checked)
	# print("Gates left: ", unchecked_children.size())
	return unchecked_children.size() == 0

func player_crashed():
	airplane.turn_engine_off()
	airplane.crashed() # tell plane it crashed so it stops moving
	player_crashed_overlay.visible = true
	
	$UI/HUD.visible = false # hide plane instruments at top

	# create particle effect of splashing
	# VERY important to add splash_object to scene tree before
	# setting global position. 
	var splash_object: GPUParticles3D = splash.instantiate()
	add_child(splash_object)
	splash_object.global_position = airplane.global_position
	
	$Camera/ScreenShake.camera_shake_impulse(1.3, 0.4)
	
	# restart the level after 4 seconds
	await get_tree().create_timer(9.0).timeout # waits for 1 second
	SceneTransition.change_scene("res://Levels/Level1.tscn")
