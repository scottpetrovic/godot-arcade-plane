extends Node3D

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gpu_particles_3d.emitting = true
