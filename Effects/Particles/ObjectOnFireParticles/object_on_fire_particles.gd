class_name ObjectOnFireParticles
extends GPUParticles3D

var object_to_follow: Node3D
var object_to_follow_destroyed: bool = false

func set_object_to_follow(obj: Node3D) -> void:
	object_to_follow = obj

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if is_instance_valid(object_to_follow):
		global_position = object_to_follow.global_position # follow object
		
		if emitting == false:
			emitting = true
	else:
		# this should fire once the object is removed from the tree
		# we can start cleanup process now for these effects
		object_to_follow_was_destroyed() 
		
func object_to_follow_was_destroyed() -> void:
	
	if object_to_follow_destroyed == false:
		object_to_follow_destroyed = true
		emitting = false
		
		# wait for lifetime to clear all remaining smoke, then delete particles
		print('about to delete particles')
		await get_tree().create_timer(lifetime + 4.0).timeout
		queue_free()
