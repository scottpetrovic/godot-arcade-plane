extends GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.emitting = true
	self.finished.connect(finished_animation)
	
func finished_animation():
	queue_free() # remove from scene
