extends Node3D

# HUD display items to always show
@onready var speed_label: Label = $UI/HUD/SpeedLabel
@onready var altitude_label: Label = $UI/HUD/AltitudeLabel
@onready var time_label: Label = $UI/HUD/TimeLabel

@onready var player_skydiver: CharacterBody3D = $PlayerSkydiver
var elapsed_time: float = 0.0

var splash: PackedScene = load("res://Ocean/SplashParticles.tscn")

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
	update_hud(delta)

func player_crashed():
	player_skydiver.crashed() # tell plane it crashed so it stops moving
	$UI/HUD.visible = false # hide plane instruments at top
	
	# create particle effect of splashing
	# VERY important to add splash_object to scene tree before
	# setting global position. 
	var splash_object: GPUParticles3D = splash.instantiate()
	add_child(splash_object)
	splash_object.global_position = player_skydiver.global_position
		
	# restart the level after 4 seconds
	await get_tree().create_timer(9.0).timeout # waits for 1 second
	SceneTransition.change_scene("res://Levels/Level2.tscn")
	
	
