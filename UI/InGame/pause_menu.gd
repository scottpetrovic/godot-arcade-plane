extends ColorRect

func _ready():
	hide()  # Hide the pause menu on start

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	visible = !visible
