extends Control

@onready var repeat_texture: TextureRect = $RepeatTexture
@onready var instructor_message: Label = $InstructorMessage

var start_showing_text: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instructor_message.visible_ratio = 0.0
	await get_tree().create_timer(2.0).timeout
	start_showing_text = true
	await get_tree().create_timer(10.0).timeout
	SceneTransition.change_scene("res://MainMenu/MainMenu.tscn")

func _process(delta: float) -> void:
	if start_showing_text:
		instructor_message.visible_ratio += delta * 0.2
