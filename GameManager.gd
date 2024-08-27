extends Node

# keep track of global things that need to persist between scenes
var current_level_time: float = 0.0 # store in seconds
var current_level_success_status: bool = false


var current_level_number: int = 1
var current_vehicle: String = "" # Plane or Skydiving
var current_map: String = "" # AircraftCarrier or Airport

var is_level_1_finished: bool = false
var level_1_best_time: float = 0.0 #  0 == not beat

var is_level_2_finished: bool = false
var level_2_best_time: float = 0.0 #  0 == not beat

func set_current_level(lvl_number: int, cur_vehicle: String, cur_map: String): 
	current_level_number = lvl_number
	current_vehicle = cur_vehicle
	current_map = cur_map
	emit_signal("level_changed")

func set_current_map(cur_map: String):
	current_map = cur_map

func set_current_vehicle(cur_vehicle: String):
	current_vehicle = cur_vehicle

func go_to_map_selection():
	SceneTransition.change_scene("res://UI/MapSelect.tscn")

func go_to_vehicle_selection_screen():
	SceneTransition.change_scene("res://UI/VehicleSelect.tscn")

func set_level_complete(level_number: int, level_time: float):

	current_level_time = level_time

	if level_number == 1:
		is_level_1_finished = true
		
		if current_level_time > level_1_best_time:
			level_1_best_time = current_level_time 

	if level_number == 2:
		is_level_2_finished = true
		
		if current_level_time > level_2_best_time:
			level_2_best_time = current_level_time

func go_to_next_level():
	
	current_level_success_status = false # reset current level success

	if current_vehicle == "Plane":
		SceneTransition.change_scene("res://Levels/PlaneLevel.tscn")
	
	if current_vehicle == "Skydiving":
		SceneTransition.change_scene("res://Levels/SkydivingLevel.tscn")

	GlobalAudio.start_music_theme()


func format_elapsed_time(elapsed: float) -> String:
	var minutes = int(elapsed/ 60.0)
	var seconds = int(elapsed) % 60
	return str(minutes) + ":" + str(seconds).pad_zeros(2)

func find_base_node() -> Node3D:
	var root = get_tree().root
	for child in root.get_children():
		if child is Node3D:
			return child
	return null
