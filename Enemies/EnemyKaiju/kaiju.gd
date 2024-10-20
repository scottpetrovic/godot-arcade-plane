extends AnimatableBody3D
@onready var health_system: HealthSystem = HealthSystem.new()
@export var starting_health = 50
@onready var kaiju_movement: Node = $KaijuMovement


var is_dead: bool = false

signal retreat()

func _ready() -> void:
	self.add_to_group('radar_target')
	GameManager.current_level_remaining_enemies += 1

	add_child(health_system)
	health_system.death.connect(lost_all_health)
	health_system.set_starting_health(starting_health)

func hit() -> void:
	health_system.take_damage(1.0)

func lost_all_health():
	# make sure this doesn't get called twice
	if is_dead == true:
		return

	is_dead = true	

	emit_signal("retreat")
	GameManager.current_level_remaining_enemies -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
