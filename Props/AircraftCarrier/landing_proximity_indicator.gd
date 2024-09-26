extends Area3D

var ignoring_area_entered: bool = true

# The whole purpose of this object/script is to see if the 
# airplane is close enough to land. If it is, change landing gear
func _on_body_entered(body: Node3D) -> void:

	if body.name == 'Airplane':
		
		# ignoring the first entry of the aircraft
		# need to turn this off if we start in the air
		if ignoring_area_entered:
			ignoring_area_entered = false
			return
		
		body.open_landing_gears(true)


func _on_body_exited(body: Node3D) -> void:
	if body.name == 'Airplane':
		ignoring_area_entered = false
		body.open_landing_gears(false)
