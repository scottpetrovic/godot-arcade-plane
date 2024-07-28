extends Node

var time_start = 0
var time_now = 0

func _process(delta):
	time_now += delta 
	var time_elapsed = time_now - time_start

func get_elapsed_time():
	return time_now - time_start
