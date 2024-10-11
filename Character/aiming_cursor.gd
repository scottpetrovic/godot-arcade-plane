extends Node3D

var viewport: Viewport
var camera: Camera3D

@onready var cursor_2d: Sprite2D = $Cursor2D

func _ready():
	viewport = get_viewport()
	camera = viewport.get_camera_3d()


func _process(delta):
	if camera:
		# Project 3D position to 2D screen space
		var cursor_2d_position = camera.unproject_position(global_position)
		
		# Update 2D cursor position
		cursor_2d.global_position = cursor_2d_position
