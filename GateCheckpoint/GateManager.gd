extends Node

func are_all_gates_passed():
	var unchecked_children = get_children().filter(func(x): return not x.is_checked)
	# print("Gates left: ", unchecked_children.size())
	return unchecked_children.size() == 0
