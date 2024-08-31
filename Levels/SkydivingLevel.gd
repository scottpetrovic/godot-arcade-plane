extends Node3D

# UI elements display items to always show
@onready var altitude_label: Label = $UI/HUD/AltitudeLabel
@onready var time_label: Label = $UI/HUD/TimeLabel
@onready var training_complete_overlay: CenterContainer = $UI/TrainingCompleteOverlay
@onready var player_crashed_overlay: CenterContainer = $UI/PlayerCrashedOverlay
@onready var checkpoints_passed_overlay: CenterContainer = $UI/CheckpointsPassedOverlay

@onready var player_skydiver: CharacterBody3D = $PlayerSkydiver
@onready var player_skydiver_camera_target: Node3D = $PlayerSkydiver/CameraFollowTarget

@onready var ui_controls: Control = $UI

@onready var camera_3d: Camera3D = $Camera3D

var elapsed_time: float = 0.0

var splash: PackedScene = load("res://Effects/Particles/SplashParticles.tscn")

var environment: Node3D # dynamicall added from Game manager config
var has_passed_through_all_checkpoints: bool = false

var map_aircraft_carrier: PackedScene = load("res://Environment/MapAircraft/MapAircraft.tscn")
var map_airport: PackedScene = load("res://Environment/MapAirport/MapAirport.tscn")

var is_testing: bool = false


func _ready():
	setup_level()
	setup_player()


func setup_level():
	
	EventBus.player_crashed.connect(on_player_crash)
	EventBus.skydiver_landed_on_target.connect(on_skydiver_hit_target)
	EventBus.skydiver_landed_off_target.connect(on_skydiver_missed_target)
	
	ui_controls.show_speedometer(false) # don't show speed we are falling
	
	if is_testing:
		GameManager.current_map = Constants.MAP.AIRCRAFTCARRIER
	
	# load map depending on what our current map is
	if GameManager.current_map == Constants.MAP.AIRCRAFTCARRIER:
		environment = map_aircraft_carrier.instantiate()
	elif GameManager.current_map == Constants.MAP.AIRPORT:
		environment = map_airport.instantiate()
	
	# Setup. depending on level, maybe need to move plane around, turn off gates
	add_child(environment)
	player_skydiver.global_position = environment.skydiver_starting_position()
	
	ui_controls.turn_on_speed_lines()


func setup_player():
	# Connect the parachute_deployed signal to the _on_parachute_deployed function
	player_skydiver.parachute_deployed.connect(_on_parachute_deployed)
	$Camera3D/ScreenShake.start_constant_shake(0.006) # always have slight screen shake


func _on_parachute_deployed():
	change_camera_to_follow()
	ui_controls.turn_off_speed_lines()
	
	$Camera3D/ScreenShake.stop_constant_shake()

func change_camera_to_follow():
	# Change the script attached to the Camera3D object to follow player
	var camera_script = load("res://Effects/CameraFollow.gd")
	camera_3d.set_script(camera_script)
	camera_3d.target = player_skydiver_camera_target
	camera_3d.should_look_at_target = true
	

func change_camera_to_orbit():
	var camera_script = load("res://Effects/CameraOrbit.gd")
	camera_3d.set_script(camera_script)
	camera_3d.target = player_skydiver_camera_target

func update_hud(delta: float):

	var altitude_multiplier = 5.0 # magic number that looks better on UI

	var altitude_string = str(int(player_skydiver.global_transform.origin.y * altitude_multiplier))
	altitude_label.text = altitude_string.pad_zeros(5)
	
	elapsed_time += delta
	time_label.text = GameManager.format_elapsed_time(elapsed_time)


func _process(delta: float) -> void:

	# stop processing new things as we are done. we should have already kicked off the 
	# reset of the process to finish level
	if player_skydiver.get_landed() == false:
		update_hud(delta)
		
	# show message when all gates are passed
	if environment.are_all_gates_passed() && has_passed_through_all_checkpoints == false:
		has_passed_through_all_checkpoints = true
		# show the UI to land for a couple seconds
		checkpoints_passed_overlay.visible = true
		GlobalAudio.play_objectives_complete_sfx()
		await get_tree().create_timer(Constants.WAITTIME.OBJECTIVES_PASSED).timeout
		checkpoints_passed_overlay.visible = false


func goal_completed():
	training_complete_overlay.visible = true
	GlobalAudio.start_level_complete()
	change_camera_to_orbit()
	await get_tree().create_timer(Constants.WAITTIME.MISSION_COMPELTE).timeout
	GameManager.current_level_time = elapsed_time
	GameManager.current_level_objectives_score = environment.percentage_of_all_gates_passed() * 100
	GameManager.go_to_mission_overview(true)

func on_player_crash(location: String):
	player_skydiver.landed() 
	GlobalAudio.start_crashed_music()
	$UI/HUD.visible = false # hide plane instruments at top
	player_crashed_overlay.visible = true
	change_camera_to_orbit()
	
	if location == 'ground':
		# only do screen shake if we didn't open our parachute on ground
		if player_skydiver.is_parachute_activated == false:
			$Camera3D/ScreenShake.camera_shake_impulse(1.0, 1.4)
	
	if location == 'water':
		var splash_object: GPUParticles3D = splash.instantiate()
		add_child(splash_object)
		splash_object.global_position = player_skydiver.global_position
		$Camera3D/ScreenShake.camera_shake_impulse(1.0, 1.4)

	# restart the level after X seconds
	await get_tree().create_timer(Constants.WAITTIME.MISSION_COMPELTE).timeout # waits for X second
	GameManager.current_level_success_status = false
	GameManager.current_level_time = elapsed_time
	GameManager.current_level_parachute_landing_score = 0
	GameManager.go_to_mission_overview()

func on_skydiver_missed_target():

	if player_skydiver.is_parachute_activated == false:
		on_player_crash("ground")
		return

	GameManager.current_level_parachute_landing_score = 0
	GameManager.current_level_success_status = false
	player_skydiver.landed()
	goal_completed()

func on_skydiver_hit_target(points: float):
	
	# add is_level_complete == false to make sure this only runs one time
	if player_skydiver.is_parachute_activated == false:
		on_player_crash("ground")
		return

	GameManager.current_level_parachute_landing_score = points
	GameManager.current_level_success_status = true
	player_skydiver.landed()
	goal_completed()
