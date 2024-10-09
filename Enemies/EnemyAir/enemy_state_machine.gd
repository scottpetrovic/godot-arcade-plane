class_name EnemyStateMachine
extends Node

# State Machine: Defines possible states for the enemy aircraft
enum State {PATROL, PURSUE, RETURN, ATTACK}  # Added ATTACK state for future implementation

@onready var enemy: CharacterBody3D = $".."
@onready var enemy_movement: Node = $"../EnemyMovement"
@onready var simple_ai_shooter: Node = $"../SimpleAIShooter"
@onready var line_of_sight: EnemyLineOfSight = $"../LineOfSight"

var current_state = State.PATROL
var player_in_line_of_sight: bool = false
var player: Player


func _ready() -> void:
	line_of_sight.found_player_visuals.connect(_spotted_player)
	line_of_sight.lost_player_visuals.connect(_lost_player)


func _process(delta: float) -> void:
	_check_for_player_if_not_exist()
	_update_state_machine()


func _check_for_player_if_not_exist():
	if is_instance_valid(player) == false:
		player = GameManager.get_player()


func _spotted_player() -> void:
	player_in_line_of_sight = true


func _lost_player() -> void:
	player_in_line_of_sight = false


func _update_state_machine() -> void:
		# State Machine Flow:
	# 1. Each frame, execute behavior based on current state
	# 2. Check conditions for state transitions after executing behavior
	match current_state:
		State.PATROL:
			check_if_player_is_seen() # PURSUE if we see player
		State.PURSUE:
			check_if_lost_player_visuals()  # RETURN back to patrol if we lost player
			check_if_we_can_attack()  # ATTACK player if we are close enough
		State.RETURN:
			check_if_player_is_seen() # PURSUE if we see player on our return
			check_if_at_start_of_patrol_position() # PATROL if we reach start point
		State.ATTACK:
			check_if_we_are_out_of_shooting_range() # PURSUE is we are out of attacking range


func check_if_at_start_of_patrol_position():
	# Once back at patrol center, resume patrolling
	if _distance_to_starting_patrol_position() < 1:
		current_state = State.PATROL

func check_if_player_is_seen():
	if player_in_line_of_sight:
		current_state = State.PURSUE

func check_if_we_are_out_of_shooting_range():
	if _in_attack_range() == false:
		current_state = State.PURSUE

func check_if_lost_player_visuals():
	if player_in_line_of_sight == false:
		current_state = State.RETURN

func _in_attack_range() -> bool:
	var distance_to_player: float = enemy.global_position.distance_to(player.global_position)
	return distance_to_player < simple_ai_shooter.attack_range

func check_if_we_can_attack():
	if _in_attack_range():
		current_state = State.ATTACK

func _distance_to_starting_patrol_position() -> float :
	return (enemy_movement.patrol_starting_position - enemy.global_position).length()
