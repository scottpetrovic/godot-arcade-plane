extends Node2D


func start_music_mission_debrief():
	change_audio_stream("res://Assets/Music/Post-Flight Analysis.mp3")

func start_music_theme():
	change_audio_stream("res://Assets/Music/Theme-song.mp3")
	
func start_level_complete():
	change_audio_stream("res://Assets/Music/Level-Complete.mp3")

func start_crashed_music():
	change_audio_stream("res://Assets/Music/player-crashed.mp3")

func play_objectives_complete_sfx():
	$ObjectivesCompleteSound.play()

func play_explosion_sfx():
	$Explosion.play()
	
func music_fadeout():
	$AnimationPlayer.play("fade_music")

func music_fadein():
	$AnimationPlayer.play_backwards("fade_music")


func change_audio_stream(new_audio_file_path: String):
	var new_audio_stream = ResourceLoader.load(new_audio_file_path)
	if new_audio_stream:
		$MusicPlayer.stream = new_audio_stream
		$MusicPlayer.volume_db = -3
		$MusicPlayer.play()  # Optionally, start playing the new audio stream
	else:
		print("Failed to load audio stream from path: ", new_audio_file_path)
