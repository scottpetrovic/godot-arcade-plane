extends Node3D

var wheel_impact_particles: PackedScene = load("res://Plane/LandingParticles.tscn")
var is_player_on_landing_strip: bool = false
var plane_landing_sound: AudioStreamPlayer2D

func _ready() -> void:
	self.body_entered.connect(_body_entered)
	self.body_exited.connect(_body_exited)

	# create new node with AudioStreamPlayer2D
	plane_landing_sound = AudioStreamPlayer2D.new()
	plane_landing_sound.stream = load("res://Assets/SoundFX/landing-squeal.mp3")
	plane_landing_sound.volume_db = -11.555
	plane_landing_sound.pitch_scale = 1.11
	add_child(plane_landing_sound)

func _body_entered(body: Node3D):
	
	# our level knows one we are skydiving and hit the aircraft carrier we are done
	if body.name == "PlayerSkydiver":
		is_player_on_landing_strip = true
	
	if body.name == 'Airplane':
		is_player_on_landing_strip = true
		
		var plane_current_speed: float = body.forward_speed
		
		if plane_current_speed > 1.4:
			var landing_impact: Node3D = wheel_impact_particles.instantiate()
			body.add_child(landing_impact)
			landing_impact.global_position = body.global_position
			plane_landing_sound.play() # play sound effect

func _body_exited(body: Node3D):
	if body.name == 'Airplane':
		is_player_on_landing_strip = false