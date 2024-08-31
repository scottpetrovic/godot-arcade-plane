extends Node3D

@onready var area_landing_strip: Area3D = $AreaLandingStrip
var wheel_impact_particles: PackedScene = load("res://Plane/LandingParticles.tscn")

var is_player_on_landing_strip: bool = false

# prevents smoke fx at start when plane is just sitting there
var ok_to_make_wheel_impact_fx: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_landing_strip.body_entered.connect(_body_entered)
	area_landing_strip.body_exited.connect(_body_exited)

func _body_entered(body: Node3D):
	
	# our level knows one we are skydiving and hit the aircraft carrier we are done
	if body.name == "PlayerSkydiver":
		is_player_on_landing_strip = true
	
	if body.name == 'Airplane':
		is_player_on_landing_strip = true
		
		if ok_to_make_wheel_impact_fx:
			var landing_impact: Node3D = wheel_impact_particles.instantiate()
			body.add_child(landing_impact)
			landing_impact.global_position = body.global_position
			
			# play sound effect
			$PlaneLandingSound.play()


func _body_exited(body: Node3D):
	if body.name == 'Airplane':
		is_player_on_landing_strip = false
		ok_to_make_wheel_impact_fx = true # we took off. ok to make fx now
