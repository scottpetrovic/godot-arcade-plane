extends Node

@onready var gates: Node = $Gates # rings to go through for practice
@onready var targets: Node = $Targets # small spheres to hit for practice


func are_all_gates_passed():
	var unchecked_children = gates.get_children().filter(func(x): return not x.is_checked)
	return unchecked_children.size() == 0

func percentage_of_all_gates_passed() -> float:
	var total_gates: int = 0
	var gates_complete: int = 0 

	total_gates = gates.get_children().size()
	gates_complete = gates.get_children().filter(func(x): return x.is_checked).size()

	return float(gates_complete) / float(total_gates)


func are_all_targets_hit():
	var unchecked_children = targets.get_children().filter(func(x): return not x.is_checked)
	return unchecked_children.size() == 0
