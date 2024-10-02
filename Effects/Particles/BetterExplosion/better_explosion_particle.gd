extends Node3D

@onready var main_explosion: GPUParticles3D = $MainExplosion
@onready var sparks: GPUParticles3D = $Sparks


func _ready():
	main_explosion.emitting = true
	main_explosion.one_shot = true
	
	sparks.emitting = true
	sparks.one_shot = true
	
	# Wait for particles to finish emitting, then remove the node
	await get_tree().create_timer(main_explosion.lifetime + 4.0).timeout
	queue_free()
