extends AudioStreamPlayer2D

@onready var airplane: CharacterBody3D = $".."
var base_audio_pitch = 0.8 # engine is barely on

func _process(delta: float) -> void:
	
	if airplane && airplane.forward_speed > 0.01:
		# calculate pitch
		var power_percentage = airplane.forward_speed / airplane.max_flight_speed
		
		# kind of like turning the sound off
		if power_percentage < 0.01:
			self.pitch_scale = 0.01
			return
		
		# going faster gives higher pitch
		self.pitch_scale = base_audio_pitch + power_percentage
		
