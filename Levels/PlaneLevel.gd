extends Node3D

@onready var airplane: CharacterBody3D = $Airplane

var gates_completed_message_shown: bool = false

@onready var checkpoints_passed_overlay: CenterContainer = $UI/CheckpointsPassedOverlay
@onready var training_complete_overlay: CenterContainer = $UI/TrainingCompleteOverlay
@onready var player_crashed_overlay: CenterContainer = $UI/PlayerCrashedOverlay

# HUD display items to always show
@onready var speed_label: Label = $UI/HUD/SpeedometerBackground/SpeedLabel
@onready var altitude_label: Label = $UI/HUD/AltitudeLabel
@onready var time_label: Label = $UI/HUD/TimeLabel
@onready var speed_indicator: ColorRect = $UI/HUD/SpeedometerBackground/Speedindicator

@onready var main_camera: Camera3D = $Camera

var environment: Node3D # dynamicall added from Game manager config

var elapsed_time: float = 0.0

var splash: PackedScene = load("res://Effects/Particles/SplashParticles.tscn")
var ground_debris: PackedScene = load("res://Effects/Particles/GroundCrashParticles.tscn")

var map_aircraft_carrier: PackedScene = load("res://Environment/MapAircraft/MapAircraft.tscn")
var map_airport: PackedScene = load("res://Environment/MapAirport/MapAirport.tscn")
var map_island: PackedScene = load("res://Environment/MapIsland/MapIsland.tscn")

var is_testing: bool = false

@onready var ui: Control = $UI


func _ready():
	if is_testing:
		GameManager.current_map = Constants.MAP.ISLAND
		GameManager.current_vehicle = Constants.VEHICLE.AIRPLANE
		airplane.global_position = Vector3(0,70,0)
		airplane.set_throttle(0.7) # 70% full throttle 
	
	setup_level()
	setup_plane() # make sure this is after the setup level


func setup_plane():
	# todo: some levels we need to start the plane in the air 
	if GameManager.current_map == Constants.MAP.AIRPORT:
		var plane_starting_pos: Node3D = environment.get_plane_starting_transform_1()
		airplane.global_position = plane_starting_pos.global_position
		airplane.rotation_degrees = plane_starting_pos.rotation_degrees
		airplane.set_throttle(0.7) # 70% full throttle 
		
		# move camera too to position and rotation
		main_camera.global_position = plane_starting_pos.global_position
		main_camera.rotation_degrees = plane_starting_pos.rotation_degrees


func setup_level():
	
	EventBus.player_crashed.connect(on_player_crash)
	
	# load map depending on what our current map is
	if GameManager.current_map == Constants.MAP.AIRCRAFTCARRIER:
		environment = map_aircraft_carrier.instantiate()		
	elif GameManager.current_map == Constants.MAP.AIRPORT:
		environment = map_airport.instantiate()
	elif GameManager.current_map == Constants.MAP.ISLAND:
		environment = map_island.instantiate()
	
	# Setup. depending on level, maybe need to move plane around, turn off gates
	add_child(environment)
	
	# set up radar by telling UI of player reference
	ui.set_player_reference(airplane)


func is_mission_complete() -> bool:
	# all gates are passed
	# airplane is currently on landing strip
	# airplane has come to a stop
	if environment.is_player_on_landing_pad() && environment.are_all_gates_passed():
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
	time_label.text = GameManager.format_elapsed_time(elapsed_time)

	update_speed_indicator()
	apply_speed_lines()

func apply_speed_lines():
	# if going more than 85% speed, turn on speed lines to help indicate speed
	var plane_speed_percentage = airplane.forward_speed / airplane.max_flight_speed
	if plane_speed_percentage > 0.85:
		$UI.turn_on_speed_lines()
	else:
		$UI.turn_off_speed_lines()


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


func camera_screenshake():
	
	# if plane is going 90% speed or more, do a constant screen shake to show speed
	# TODO: airplane needs to send a signal when reaching this treshold
	if (airplane.forward_speed / airplane.max_flight_speed) > .9:
		$Camera/ScreenShake.start_constant_shake(0.02)
	else:
		$Camera/ScreenShake.stop_constant_shake()


func _process(delta: float) -> void:
	
	# stop updating UI when we are complete
	# this also upates time mission is taking
	if is_mission_complete() == false:
		update_hud(delta)
		
	camera_screenshake()
	
	# maybe show this on the UI somewhere?
	if environment.are_all_gates_passed() && gates_completed_message_shown == false:
		gates_completed_message_shown = true
		# show the UI to land for a couple seconds
		checkpoints_passed_overlay.visible = true
		GlobalAudio.play_objectives_complete_sfx()
		await get_tree().create_timer(Constants.WAITTIME.OBJECTIVES_PASSED).timeout
		checkpoints_passed_overlay.visible = false

	if is_mission_complete():
		goal_completed()


func goal_completed():
	# make sure to only call this one time
	if training_complete_overlay.visible == false:
		airplane.set_allow_movement(false)
		training_complete_overlay.visible = true
		GlobalAudio.start_level_complete()
		change_camera_to_orbit()
		await get_tree().create_timer(Constants.WAITTIME.MISSION_COMPELTE).timeout
		GameManager.current_level_success_status = true
		GameManager.current_level_time = elapsed_time
		GameManager.current_level_objectives_score = environment.percentage_of_all_gates_passed() * 100
		GameManager.go_to_mission_overview(false)
		# TODO: Controls for controller
		# TODO: export to HTML5
		# TODO: pause screen
		# TODO: controls if on mobile


func change_camera_to_orbit():
	var camera_script = load("res://Effects/Camera/CameraOrbit.gd")
	main_camera.set_script(camera_script)
	main_camera.target = airplane

func on_player_crash(location: String):
	player_crashed_overlay.visible = true
	GlobalAudio.start_crashed_music()
	GlobalAudio.play_explosion_sfx()
	change_camera_to_orbit()
	$UI/HUD.visible = false # hide plane instruments at top
	$Camera/ScreenShake.camera_shake_impulse(1.3, 0.4)
	airplane.set_allow_movement(false)

	if location == 'ground':
		var explosion_effects: Node3D = ground_debris.instantiate()
		airplane.add_child(explosion_effects)
		
	if location == 'water':
		var splash_object: GPUParticles3D = splash.instantiate()
		add_child(splash_object)
		splash_object.global_position = airplane.global_position
	
	# restart the level after X seconds
	await get_tree().create_timer(Constants.WAITTIME.MISSION_COMPELTE).timeout # waits for X second
	GameManager.current_level_time = elapsed_time
	GameManager.current_level_success_status = false
	GameManager.go_to_mission_overview()
