extends GPUParticles3D

func _ready():
	emitting = true
	
	# Wait for particles to finish emitting, then remove the node
	await get_tree().create_timer(lifetime * 4.0).timeout
	queue_free()
