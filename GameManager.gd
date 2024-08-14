extends Node3D

@onready var gates: Node = $Gates

@onready var checkpoints_passed_overlay: CenterContainer = $UI/CheckpointsPassedOverlay


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# maybe show this on the UI somewhere?
	if are_all_gates_passed():
		# show the UI to land
		checkpoints_passed_overlay.visible = true
	
func are_all_gates_passed():
	var unchecked_children = gates.get_children().filter(func(x): return not x.is_checked)
	print("Gates left: ", unchecked_children.size())
	return unchecked_children.size() == 0
