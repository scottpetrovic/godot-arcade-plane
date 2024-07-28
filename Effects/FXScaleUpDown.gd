extends Node

var time_start = 0
var time_now = 0
@export var scale_amount = 0.3

func _process(delta):
	time_now += delta 
	var time_elapsed = time_now - time_start
	
	# slowly scale in and out to make more interesting
	# sin goes between -1 and 1
	var sinValue = sin(time_elapsed)

	# we want the model to scale just a bit between 0.9 and 1.1
	# multiply by .3 will make sinValue go from -.3 to .3
	var newScale = (sinValue * scale_amount) + 1
	
	self.get_parent().scale = Vector3(newScale, newScale, newScale)	


func get_elapsed_time():
	return time_now - time_start
