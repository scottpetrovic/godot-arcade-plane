extends Node

func pulse():
	var tween = get_tree().create_tween()
	tween.tween_property(get_parent(), "scale", Vector3(1.4,1.4,1.4), 0.25)
	tween.tween_property(get_parent(), "scale", Vector3(0.6,0.6,0.6), 0.25)
	tween.tween_property(get_parent(), "scale", Vector3(1.4,1.4,1.4), 0.25)
	tween.tween_property(get_parent(), "scale", Vector3(0.6,0.6,0.6), 0.25)
