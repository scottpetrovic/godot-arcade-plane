extends Node3D

@onready var gates: Node = $Gates
@onready var checkpoints_passed_overlay: CenterContainer = $UI/CheckpointsPassedOverlay
@onready var aircraft_carrier: Node3D = $AircraftCarrier
@onready var airplane: CharacterBody3D = $Airplane

var gates_completed_message_shown: bool = false

func check_for_final_landing() -> bool:
	# all gates are passed
	# airplane is currently on landing strip
	# airplane has come to a stop
	# print(aircraft_carrier.is_player_on_landing_strip, are_all_gates_passed(), airplane.forward_speed)
	if aircraft_carrier.is_player_on_landing_strip && are_all_gates_passed():
		if airplane.forward_speed < 0.01:
			return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# maybe show this on the UI somewhere?
	if are_all_gates_passed() && gates_completed_message_shown == false:
		gates_completed_message_shown = true
		# show the UI to land for a couple seconds
		checkpoints_passed_overlay.visible = true
		await get_tree().create_timer(2.0).timeout
		checkpoints_passed_overlay.visible = false

	if check_for_final_landing():
		goal_completed()

func goal_completed():
	print('we did it')
	# TODO: Show UI that we did a good job
	# TODO: wait a few seconds and go to a summary screen
	# TODO: UI on in-game with time taken
	# TODO: UI on in-game with rings left
	# TODO: slight fog to make horizon less harsh
	# TODO: Controls for controller
	# TODO: export to HTML5
	# TODO: controls if on mobile

func are_all_gates_passed():
	var unchecked_children = gates.get_children().filter(func(x): return not x.is_checked)
	# print("Gates left: ", unchecked_children.size())
	return unchecked_children.size() == 0
