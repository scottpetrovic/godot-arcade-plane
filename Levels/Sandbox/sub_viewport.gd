extends Camera3D

@onready var main_camera: Camera3D = $"../../../Camera3D"
@onready var turn_on_delay_timer: Timer = $TurnOnDelayTimer
@onready var sub_viewport_container: SubViewportContainer = $"../.."
@onready var airplane: Player = $"../../../Airplane"


func _ready():
	current = false
	EventBus.player_attacked_from_behind.connect(_player_attacked)
	turn_on_delay_timer.wait_time = 5.0
	turn_on_delay_timer.one_shot = true
	turn_on_delay_timer.timeout.connect(_show_timer_expired)

	sub_viewport_container.visible = false # hide by default

func _show_timer_expired() -> void:
		sub_viewport_container.visible = false

func _player_attacked() -> void:

	# if we are getting attacked, show rear view window, 
	# and have time to turn it off if we are not being attacked
	sub_viewport_container.visible = true
	turn_on_delay_timer.start()

func _process(delta):
	# Update rear camera position and rotation
	global_transform = airplane.get_node("ReviewViewCameraArea").global_transform
	rotate_y(PI)  # Rotate 180 degrees to look behind
