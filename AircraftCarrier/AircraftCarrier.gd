extends Node3D

@onready var area_landing_strip: Area3D = $AreaLandingStrip

signal character_collided(body: Node3D)

var is_player_on_landing_strip: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_landing_strip.body_entered.connect(_body_entered)
	area_landing_strip.body_exited.connect(_body_exited)

func _body_entered(body: Node3D):
	if body.name == 'Airplane':
		is_player_on_landing_strip = true

func _body_exited(body: Node3D):
	if body.name == 'Airplane':
		is_player_on_landing_strip = false
