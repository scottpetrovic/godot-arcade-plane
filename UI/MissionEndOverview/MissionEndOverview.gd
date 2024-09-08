extends Control

@onready var repeat_texture: TextureRect = $RepeatTexture
@onready var instructor_message: Label = $InstructorMessage
@onready var time_score: Label = $VBoxContainer/TimeLayout/ValueLabel
@onready var landing_score: Label =  $VBoxContainer/LandingLayout/ValueLabel
@onready var objectives_score: Label = $VBoxContainer/ObjectiveLayout/ValueLabel
@onready var total_score: Label = $VBoxContainer/TotalScoreLayout/ValueLabel


var start_showing_text: bool = false

func change_audio_stream(new_audio_file_path: String):
	var new_audio_stream = ResourceLoader.load(new_audio_file_path)
	if new_audio_stream:
		var global_audio: AudioStreamPlayer2D = GlobalAudio.get_node("MusicPlayer")
		global_audio.stream = new_audio_stream
		global_audio.play()  # Optionally, start playing the new audio stream
	else:
		print("Failed to load audio stream from path: ", new_audio_file_path)

func _ready() -> void:
	
	# 2 minutes or more will get a score of 0 (120)
	var time_points = int(max(120 - GameManager.current_level_time, 0))
	
	if GameManager.current_level_success_status == false:
		time_points = 0 # don't give any points to time if we failed
	
	time_score.text = GameManager.format_elapsed_time(GameManager.current_level_time) 
	# time_score.text += " (" + str(time_points) + ") PTS"
	objectives_score.text = str(GameManager.current_level_objectives_score) + " PTS"
	
	
	if GameManager.current_vehicle == Constants.VEHICLE.SKYDIVER:
		landing_score.text = str( int(GameManager.current_level_parachute_landing_score)) + " PTS"


	total_score.text = str(int(GameManager.current_level_objectives_score + GameManager.current_level_parachute_landing_score + time_points)) 
	total_score.text += " PTS"


	# eventually find out what type of scores will mean we are passed
	# if we fail, we will not se the level to complete
	if GameManager.current_level_success_status == true:
		GameManager.set_level_complete(GameManager.current_level_number, GameManager.current_level_time)
	else:
		instructor_message.text = "Well that didn't turn out so well. Let's try this one more time - Claire"
	
	instructor_message.visible_ratio = 0.0
	await get_tree().create_timer(2.0).timeout
	start_showing_text = true
	await get_tree().create_timer(10.0).timeout
	GlobalAudio.start_music_theme()
	GameManager.go_to_map_selection()

func _process(delta: float) -> void:
	if start_showing_text:
		instructor_message.visible_ratio += delta * 0.2
