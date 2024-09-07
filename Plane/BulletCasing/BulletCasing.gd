extends RigidBody3D

var lifetime = 20.0  # Time in seconds before the casing disappears

func _ready():
	# Apply a random rotation to make the ejection look more natural
	angular_velocity = Vector3(randf_range(-10, 10), randf_range(-10, 10), randf_range(-10, 10))
	
	# Set up a timer to remove the casing after its lifetime
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _integrate_forces(state):
	# Apply some drag to slow down the casing over time
	state.linear_velocity *= 0.98
	state.angular_velocity *= 0.98
