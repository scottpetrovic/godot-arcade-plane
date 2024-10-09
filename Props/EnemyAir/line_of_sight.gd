class_name EnemyLineOfSight
extends Area3D

signal found_player_visuals()
signal lost_player_visuals()

func _ready() -> void:
	body_entered.connect(_on_line_of_sight_body_entered)
	body_exited.connect(_on_line_of_sight_body_exited)

func _on_line_of_sight_body_entered(body: Node3D):
	if body is Player:
		print('found player visuals')
		emit_signal("found_player_visuals")

func _on_line_of_sight_body_exited(body: Node3D):
	if body is Player:
		emit_signal("lost_player_visuals")
