extends Area3D

@onready var level_node: Node3D = null

func _ready() -> void:
	self.body_entered.connect(body_entered_event)
	level_node = find_base_node()

func body_entered_event(body: Node3D):
	if body.name == "Airplane" || body.name == "PlayerSkydiver":
		level_node.player_crashed()

# get the root node of what we are working on.
func find_base_node() -> Node3D:
	var root = get_tree().root
	for child in root.get_children():
		if child is Node3D:
			return child
	return null
