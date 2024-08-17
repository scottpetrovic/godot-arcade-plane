extends Control

@onready var repeat_texture: TextureRect = $RepeatTexture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(8.0).timeout
	SceneTransition.change_scene("res://MainMenu/MainMenu.tscn")

func _process(delta: float) -> void:
	pass
