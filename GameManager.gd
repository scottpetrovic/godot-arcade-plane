extends Node

# keep track of global things that need to persist between scenes
var current_level: int = 0
var current_level_score: int = 0

var is_level_0_complete: bool = false
var level_0_best_score: int = 0 #  0 == not beat


func set_level_score(level_index: int, level_score):

	current_level_score = level_score

	if level_index == 0:
		is_level_0_complete = true
		
		if current_level_score > level_0_best_score:
			level_0_best_score = current_level_score 
