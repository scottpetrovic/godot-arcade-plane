extends AnimatableBody3D

# TODO
# add animation player 
# make some animations for walking and screaming

# figure out how to move head to always be looking at player
# then, add logic to only look at player within vision cone




func _ready() -> void:
	self.add_to_group('radar_target')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
