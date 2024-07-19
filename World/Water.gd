extends Area3D

@onready var airplane: CharacterBody3D = $"../Airplane"

var splash: PackedScene = load("res://World/SplashParticles.tscn")
@onready var utility_functions: Node3D = $"../UtilityFunctions"


func _ready() -> void:
	self.body_entered.connect(body_entered_event)


func body_entered_event(body: Node3D):
	
	if body == airplane:

		body.crashed() # tell plane it crashed so it stops moving

		# create particle effect of splashing
		# VERY important to add splash_object to scene tree before
		# setting global position. 
		var splash_object: GPUParticles3D = splash.instantiate()
		add_child(splash_object)
		splash_object.global_position = body.global_position

		
		utility_functions.camera_shake(1.7, 1.0)
		
		# restart the level after 4 seconds
		await get_tree().create_timer(9.0).timeout # waits for 1 second
		restart_scene()
		
func restart_scene():
	get_tree().reload_current_scene()
