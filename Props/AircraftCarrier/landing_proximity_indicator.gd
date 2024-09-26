extends Area3D

# The whole purpose of this object/script is to see if the 
# airplane is close enough to land. If it is, change landing gear
func _on_body_entered(body: Node3D) -> void:
	if body.name == 'Airplane':
			body.open_landing_gears(true)

func _on_body_exited(body: Node3D) -> void:
	if body.name == 'Airplane':
		body.open_landing_gears(false)
