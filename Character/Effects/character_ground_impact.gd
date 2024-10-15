extends Area3D

var wheel_impact_particles: PackedScene = preload("res://Effects/Particles/LandingSmoke/LandingParticles.tscn")
@onready var tire_squeal_sfx: AudioStreamPlayer3D = $tire_squeal_sfx
@onready var airplane: Player = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_body_entered)

func _body_entered(_body: Node3D) -> void:

	# don't collide with our self
	if _body != airplane:
		
		# make sure we are actually moving. 
		# we will be going less if a scene starts and we fall to the ground
		if airplane.flight_controller.forward_speed > 1.0:
			tire_squeal_sfx.play()		
			# add particle puff when we hit the ground
			var landing_impact: Node3D = wheel_impact_particles.instantiate()
			get_tree().current_scene.add_child(landing_impact)
			landing_impact.global_position = global_position
