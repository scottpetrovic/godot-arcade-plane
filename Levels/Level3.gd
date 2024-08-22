extends Node3D

@onready var airplane: CharacterBody3D = $Airplane


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# plane starts in mid-air, so give it some power at start
	airplane.set_throttle(0.7) # 70% full throttle 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
