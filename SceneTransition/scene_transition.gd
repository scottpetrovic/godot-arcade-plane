extends CanvasLayer

@onready var transition_sound: AudioStreamPlayer2D = $TransitionSound
	
func change_scene(target: String, fade_music: bool = false) -> void:
	transition_sound.play()
	if fade_music:
		GlobalAudio.music_fadeout()

	$AnimationPlayer.play('dissolve')
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target)
	$AnimationPlayer.play_backwards('dissolve')
	
	if fade_music:
		GlobalAudio.music_fadein()
