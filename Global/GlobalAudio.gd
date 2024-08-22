extends Node2D


func start_music_mission_debrief():
	change_audio_stream("res://Assets/Music/Post-Flight Analysis.mp3")

func start_music_theme():
	change_audio_stream("res://Assets/Music/Theme-song.mp3")

func change_audio_stream(new_audio_file_path: String):
	var new_audio_stream = ResourceLoader.load(new_audio_file_path)
	if new_audio_stream:
		$MusicPlayer.stream = new_audio_stream
		$MusicPlayer.play()  # Optionally, start playing the new audio stream
	else:
		print("Failed to load audio stream from path: ", new_audio_file_path)
