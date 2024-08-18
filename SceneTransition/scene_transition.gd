extends CanvasLayer

@onready var transition_sound: AudioStreamPlayer2D = $TransitionSound
	
func change_scene(target: String) -> void:
	transition_sound.play()
	$AnimationPlayer.play('dissolve')
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target)
	$AnimationPlayer.play_backwards('dissolve')
