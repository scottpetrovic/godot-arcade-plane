extends Node
@onready var kaiju_movement: Node = $"../KaijuMovement"
@onready var line_of_sight: EnemyLineOfSight = $"../kaiju-puppet/body_base/LineOfSight"
@onready var animation_player_mouth: AnimationPlayer = $"../AnimationPlayerMouth"
@onready var animation_player_movement: AnimationPlayer = $"../AnimationPlayerMovement"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line_of_sight.found_player_visuals.connect(_see_player_visuals)
	line_of_sight.lost_player_visuals.connect(_lost_player_visuals)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _see_player_visuals() -> void:
	# the audio gets played as part of the animation player
	animation_player_mouth.play("mouth_open")
	
func _lost_player_visuals() -> void:
	animation_player_mouth.stop()


func _process(delta: float) -> void:
	
	
	match kaiju_movement.current_state:
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
			# TODO better animation for walking??
			if animation_player_movement.current_animation != 'idle':
				animation_player_movement.play("idle")
