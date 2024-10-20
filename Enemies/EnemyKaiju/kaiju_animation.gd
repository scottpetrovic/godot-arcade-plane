extends Node
@onready var kaiju_movement: Node = $"../KaijuMovement"
@onready var line_of_sight: EnemyLineOfSight = $"../kaiju-puppet/body_base/LineOfSight"
@onready var animation_player_mouth: AnimationPlayer = $"../AnimationPlayerMouth"
@onready var animation_player_movement: AnimationPlayer = $"../AnimationPlayerMovement"
@onready var kaiju: AnimatableBody3D = $".."
@export var audio_stream_player_3d: AudioStreamPlayer3D


var _player_reference: Player

signal done_emerging_animation()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line_of_sight.found_player_visuals.connect(_see_player_visuals)
	line_of_sight.lost_player_visuals.connect(_lost_player_visuals)
	start_animations()


func 	start_animations() -> void:
	# play roar sound effect before starting animation
	audio_stream_player_3d.play()
	audio_stream_player_3d
	await get_tree().create_timer(audio_stream_player_3d.stream.get_length() + 3.0).timeout

	# we have the emerge animation loaded, but will turn it active
	# once we begin. This will help the model start underground
	# if we don't do this, there will be a quick ghost at 0,0,0
	animation_player_movement.active = true

func _see_player_visuals() -> void:
	# the audio gets played as part of the animation player
	animation_player_mouth.play("mouth_open")
	
	
	
func _lost_player_visuals() -> void:
	animation_player_mouth.stop()

func animation_callback_retreat() -> void:
	GameManager.create_crater(kaiju.global_position, 3.0)

func animation_callback_roar() -> void:
	var main_camera: Camera3D = get_viewport().get_camera_3d()
	main_camera.get_node("ScreenShake").camera_shake_impulse(.18, 2.0)

func animation_callback_foot_stomp() -> void:

	# if player is on ground, cause a little screen shake
	if _player_reference.is_on_floor():
		var main_camera: Camera3D = get_viewport().get_camera_3d()
		main_camera.get_node("ScreenShake").camera_shake_impulse(.02, 1.6)

# we have done everything, animation callback will destroy kaiju object
func animation_callback_destroy() -> void:
	kaiju.queue_free()

func animation_callback_done_emerging() -> void:
	emit_signal("done_emerging_animation")

func _process(delta: float) -> void:
	
	if is_instance_valid(_player_reference) == false:
		_player_reference = GameManager.get_player()
		return
	
	match kaiju_movement.current_state:
		kaiju_movement.State.EMERGE:
			if animation_player_movement.current_animation != 'emerge':
				animation_player_movement.play("emerge")
		kaiju_movement.State.IDLE:
			if animation_player_movement.current_animation != 'idle':
				animation_player_movement.play("idle")
		kaiju_movement.State.MOVING:
			if animation_player_movement.current_animation != 'walk':
				animation_player_movement.play("walk")
		kaiju_movement.State.LOOKING:
			# State transition handled by timer
			pass
		kaiju_movement.State.TURNING:
			if animation_player_movement.current_animation != 'walk':
				animation_player_movement.play("walk")
		kaiju_movement.State.RETREAT:
			if animation_player_movement.current_animation != 'retreat':
				animation_player_movement.play("retreat")
