extends Node3D

@onready var gates: Node = $Gates

@onready var checkpoints_passed_overlay: CenterContainer = $UI/CheckpointsPassedOverlay

var gates_completed_message_shown: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# maybe show this on the UI somewhere?
	if are_all_gates_passed() && gates_completed_message_shown == false:
		gates_completed_message_shown = true
		# show the UI to land for a couple seconds
		checkpoints_passed_overlay.visible = true
		await get_tree().create_timer(2.0).timeout
		checkpoints_passed_overlay.visible = false

		
	
func are_all_gates_passed():
	var unchecked_children = gates.get_children().filter(func(x): return not x.is_checked)
	# print("Gates left: ", unchecked_children.size())
	return unchecked_children.size() == 0
