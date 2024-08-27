extends Node3D

# HUD display items to always show
@onready var altitude_label: Label = $UI/HUD/AltitudeLabel
@onready var time_label: Label = $UI/HUD/TimeLabel
@onready var training_complete_overlay: CenterContainer = $UI/TrainingCompleteOverlay
@onready var player_crashed_overlay: CenterContainer = $UI/PlayerCrashedOverlay

@onready var player_skydiver: CharacterBody3D = $PlayerSkydiver
@onready var player_skydiver_camera_target: Node3D = $PlayerSkydiver/CameraFollowTarget

@onready var camera_3d: Camera3D = $Camera3D

var elapsed_time: float = 0.0

var splash: PackedScene = load("res://Effects/Particles/SplashParticles.tscn")

var environment: Node3D # dynamicall added from Game manager config

var map_aircraft_carrier: PackedScene = load("res://Environment/MapAircraft/MapAircraft.tscn")
var map_airport: PackedScene = load("res://Environment/MapAirport/MapAirport.tscn")

var is_level_complete: bool = false

func _ready():
	setup_level()
	setup_player()

func setup_level():
	# load map depending on what our current map is
	if GameManager.current_map == 'AircraftCarrier':
		environment = map_aircraft_carrier.instantiate()		
	elif GameManager.current_map == 'Airport':
		environment = map_airport.instantiate()
	
	# Setup. depending on level, maybe need to move plane around, turn off gates
	add_child(environment)
	
func setup_player():
	# Connect the parachute_deployed signal to the _on_parachute_deployed function
	player_skydiver.parachute_deployed.connect(_on_parachute_deployed)
	$Camera3D/ScreenShake.start_constant_shake(0.006) # always have slight screen shake

func _on_parachute_deployed():
	# Change the script attached to the Camera3D object to follow player
	var camera_script = load("res://Effects/CameraFollow.gd")
	camera_3d.set_script(camera_script)
	camera_3d.target = player_skydiver_camera_target
	camera_3d.should_look_at_target = true
	
	$Camera3D/ScreenShake.stop_constant_shake()


func update_hud(delta: float):

	var altitude_multiplier = 5.0 # magic number that looks better on UI

	var altitude_string = str(int(player_skydiver.global_transform.origin.y * altitude_multiplier))
	altitude_label.text = altitude_string.pad_zeros(5)
	
	elapsed_time += delta
	time_label.text = GameManager.format_elapsed_time(elapsed_time)


func _process(delta: float) -> void:

	# add is_level_complete == false to make sure this only runs one time
	if environment.is_player_on_landing_pad() && is_level_complete == false:
		is_level_complete = true
		
		# if mission is finished and we haven't deployed parachute, that means
		# we ran into the ground going full speed
		if player_skydiver.is_parachute_activated == false:
			player_crashed_into_ground()
		
		goal_completed()
		return
	
	if is_level_complete == false:
		update_hud(delta)

func goal_completed():
	player_skydiver.landed()
	
	if player_skydiver.is_parachute_activated == false:
		return
	
	training_complete_overlay.visible = true
	await get_tree().create_timer(4.0).timeout
	GameManager.current_level_success_status = true
	GameManager.current_level_time = elapsed_time
	SceneTransition.change_scene("res://MissionEndOverview/MissionEndOverview.tscn")

func player_crashed_into_ground():
	print('player crashed into ground ', randf())
	player_skydiver.crashed() # tell plane it crashed so it stops moving
	$UI/HUD.visible = false # hide plane instruments at top
	player_crashed_overlay.visible = true
	$Camera3D/ScreenShake.camera_shake_impulse(1.0, 1.4)
	
	# restart the level after X seconds
	await get_tree().create_timer(9.0).timeout # waits for X second
	GameManager.current_level_success_status = false
	GameManager.current_level_time = elapsed_time
	SceneTransition.change_scene("res://MissionEndOverview/MissionEndOverview.tscn")

func player_crashed_into_water():
	player_skydiver.crashed() # tell skydiver it crashed so it stops moving
	$UI/HUD.visible = false # hide plane instruments at top
	player_crashed_overlay.visible = true
	
	$Camera3D/ScreenShake.camera_shake_impulse(1.0, 1.4)

	# create particle effect of splashing
	# VERY important to add splash_object to scene tree before
	# setting global position. 
	var splash_object: GPUParticles3D = splash.instantiate()
	add_child(splash_object)
	splash_object.global_position = player_skydiver.global_position
		
	# restart the level after X seconds
	await get_tree().create_timer(9.0).timeout # waits for X second
	GameManager.current_level_success_status = false
	GameManager.current_level_time = elapsed_time
	SceneTransition.change_scene("res://MissionEndOverview/MissionEndOverview.tscn")
	
	
