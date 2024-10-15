extends Node

# This can be used to simulate multiple things like the following:
# - object in water "floating"
# - item to collect cycling up and down

@export var bob_height : float = 0.2  # The height of the bobbing motion
@export var bob_speed : float = 2.0    # larger is faster speed per cycle

var time : float = 0.0
var initial_y : float

func _ready():
	initial_y = get_parent().global_position.y

func _process(delta):
	time += delta
	var bob_offset = sin(time * bob_speed) * bob_height
	get_parent().global_position.y = initial_y + bob_offset
