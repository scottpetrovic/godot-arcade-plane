extends GPUParticles3D

@onready var water_rings_particles: GPUParticles3D = $WaterRingsParticles

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	water_rings_particles.emitting = true
	self.emitting = true
