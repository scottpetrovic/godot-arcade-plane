@tool
extends Node3D

@export var rotate_amount: float = 0.6
@onready var area_3d: Area3D = $Area3D
@onready var sfx: AudioStreamPlayer2D = $SFX

func _ready():
	area_3d.body_entered.connect(_body_entered)

func _body_entered(body:Node3D) -> void:
	
	# player picked up fuel can
	# play sound effect, then remove fuel can
	if body.is_class("Player"):
		(body as Player).fuel_system.refuel(20.0)
		visible = false
		sfx.play()
		await sfx.finished
		queue_free()

func _process(delta: float) -> void:
	# continuously rotate object around center
	rotation.y += rotate_amount * delta
