extends Node

# keep track of global things that need to persist between scenes
var current_level_number: int = 1
var current_level_time: float = 0.0 # store in seconds
var current_level_success_status: bool = false

var is_level_1_finished: bool = false
var level_1_best_time: float = 0.0 #  0 == not beat

var is_level_2_finished: bool = false
var level_2_best_time: float = 0.0 #  0 == not beat


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

	GlobalAudio.start_music_theme()

	if is_level_1_finished == false:
		SceneTransition.change_scene("res://Levels/Level1.tscn")
	else:
		SceneTransition.change_scene("res://Levels/Level2.tscn")


func format_elapsed_time(elapsed: float) -> String:
	var minutes = int(elapsed/ 60.0)
	var seconds = int(elapsed) % 60
	return str(minutes) + ":" + str(seconds).pad_zeros(2)
