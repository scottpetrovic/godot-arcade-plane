extends Node3D

# HUD display items to always show
@onready var speed_label: Label = $UI/HUD/SpeedLabel
@onready var altitude_label: Label = $UI/HUD/AltitudeLabel
@onready var time_label: Label = $UI/HUD/TimeLabel

@onready var training_complete_overlay: CenterContainer = $UI/TrainingCompleteOverlay


@onready var player_skydiver: CharacterBody3D = $PlayerSkydiver
var elapsed_time: float = 0.0

var splash: PackedScene = load("res://Ocean/SplashParticles.tscn")
@onready var aircraft_carrier: Node3D = $AircraftCarrier

var is_level_complete: bool = false

func update_hud(delta: float):

	var altitude_multiplier = 5.0 # magic number that looks better on UI

	var altitude_string = str(int(player_skydiver.global_transform.origin.y * altitude_multiplier))
	altitude_label.text = altitude_string.pad_zeros(5)
	
	elapsed_time += delta
	time_label.text = format_elapsed_time(elapsed_time)


# move this to a utility function
func format_elapsed_time(elapsed: float) -> String:
	var minutes = int(elapsed) / 60
	var seconds = int(elapsed) % 60
	return str(minutes) + ":" + str(seconds).pad_zeros(2)

func _process(delta: float) -> void:
	
	
	if aircraft_carrier.is_player_on_landing_strip && is_level_complete == false:
		is_level_complete = true
		
		if player_skydiver.is_parachute_activated == false:
			player_crashed(false)
			return
		
		goal_completed()
		return
	
	update_hud(delta)

func goal_completed():
	player_skydiver.landed()
	
	if player_skydiver.is_parachute_activated == false:
		return
	
	training_complete_overlay.visible = true
	await get_tree().create_timer(4.0).timeout
	SceneTransition.change_scene("res://MissionEndOverview/MissionEndOverview.tscn")

func player_crashed(crashed_in_water: bool = true):
	player_skydiver.crashed() # tell plane it crashed so it stops moving
	$UI/HUD.visible = false # hide plane instruments at top
	
	if crashed_in_water:
		# create particle effect of splashing
		# VERY important to add splash_object to scene tree before
		# setting global position. 
		var splash_object: GPUParticles3D = splash.instantiate()
		add_child(splash_object)
		splash_object.global_position = player_skydiver.global_position
		
	# restart the level after 4 seconds
	await get_tree().create_timer(9.0).timeout # waits for 1 second
	SceneTransition.change_scene("res://Levels/Level2.tscn")
	
	
