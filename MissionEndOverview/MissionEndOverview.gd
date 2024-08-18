extends Control

@onready var repeat_texture: TextureRect = $RepeatTexture
@onready var instructor_message: Label = $InstructorMessage
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

	instructor_message.visible_ratio = 0.0
	await get_tree().create_timer(2.0).timeout
	start_showing_text = true
	await get_tree().create_timer(10.0).timeout
	SceneTransition.change_scene("res://MainMenu/MainMenu.tscn")

func _process(delta: float) -> void:
	if start_showing_text:
		instructor_message.visible_ratio += delta * 0.2
