extends AudioStreamPlayer2D

@onready var airplane: CharacterBody3D = $".."
var base_audio_pitch = 0.8 # engine is barely on


func _process(_delta: float) -> void:

	if airplane.get_node("FlightController").is_engine_on():
		# calculate pitch
		var power_percentage = airplane.get_node("FlightController").forward_speed / airplane.get_node("FlightController").max_flight_speed
		
		# kind of like turning the sound off
		if power_percentage < 0.01:
			self.playing = false
			self.pitch_scale = 0.01
			return

		# turn sound on. without this if statement, the sound will constantly restart
		if self.playing == false:
			self.playing = true
		
		# going faster gives higher pitch
		self.pitch_scale = base_audio_pitch + power_percentage
	else:
		self.playing = false
