extends Control

@onready var repeat_texture: TextureRect = $RepeatTexture
@onready var instructor_message: Label = $InstructorMessage
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var time_score: Label = $VBoxContainer/TimeScore


var start_showing_text: bool = false

func change_audio_stream(new_audio_file_path: String):
	var new_audio_stream = ResourceLoader.load(new_audio_file_path)
	if new_audio_stream:
		var global_audio: AudioStreamPlayer2D = GlobalAudio.get_node("MusicPlayer")
		global_audio.stream = new_audio_stream
		global_audio.play()  # Optionally, start playing the new audio stream
	else:
		print("Failed to load audio stream from path: ", new_audio_file_path)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	GlobalAudio.start_music_mission_debrief()
	
	level_label.text = "Level " + str(GameManager.current_level_number)
	time_score.text = "Time: " + GameManager.format_elapsed_time(GameManager.current_level_time)

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
	GameManager.go_to_map_selection()

func _process(delta: float) -> void:
	if start_showing_text:
		instructor_message.visible_ratio += delta * 0.2
