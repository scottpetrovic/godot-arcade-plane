extends Node

@export var rotate_amount: float = 0.6

func _process(delta: float) -> void:
	# continuously rotate object around center
	self.get_parent().rotation.z += rotate_amount * delta
