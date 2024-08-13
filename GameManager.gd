extends Node3D

@onready var gates: Node = $Gates


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# maybe show this on the UI somewhere?
	# calculate_gates_passed()
	pass
	
func calculate_gates_passed():
	var unchecked_children = gates.get_children().filter(func(x): return not x.is_checked)
	var count = unchecked_children.size()
	print("Gates passed: ", count)
