extends VBoxContainer

@onready var spawn_1_button: Button = $Spawn1Button
@onready var spawn_2_button: Button = $Spawn2Button
@onready var spawn_3_button: Button = $Spawn3Button
@onready var spawn_4_button: Button = $Spawn4Button
@onready var spawn_5_button: Button = $Spawn5Button

@onready var reload_button: Button = $ReloadButton


# objects to create
@export var air_basic_enemy: PackedScene
@export var air_scout_enemy: PackedScene
@export var air_frigate_enemy: PackedScene
@export var sea_ship: PackedScene
@export var turret_block: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_1_button.pressed.connect(_spawn_1_press)
	spawn_2_button.pressed.connect(_spawn_2_press)
	spawn_3_button.pressed.connect(_spawn_3_press)
	spawn_4_button.pressed.connect(_spawn_4_press)
	spawn_5_button.pressed.connect(_spawn_5_press)
	
	reload_button.pressed.connect(reload_scene)


func reload_scene() -> void:
	var current_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(current_scene_path)

func _spawn_1_press() -> void:
	var enemy = air_basic_enemy.instantiate()
	_add_at_random_position(enemy, true)

func _spawn_2_press() -> void:
	var enemy = air_scout_enemy.instantiate()
	_add_at_random_position(enemy, true)

func _spawn_3_press() -> void:
	var enemy = sea_ship.instantiate()
	_add_at_random_position(enemy, false)

func _spawn_4_press() -> void:
	var enemy = air_frigate_enemy.instantiate()
	_add_at_random_position(enemy, true)

func _spawn_5_press() -> void:
	var enemy = turret_block.instantiate()
	_add_at_random_position(enemy, false)

func _add_at_random_position(object: Node3D, is_in_air: bool = true) -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var x = rng.randf_range(-40.0, 40.0)
	var y = rng.randf_range(2.0, 5.0)
	var z = rng.randf_range(-30.0, -50.0)

	get_tree().current_scene.add_child(object)
	
	if is_in_air:
		object.global_position = Vector3(x,y,z)
	else:
		object.global_position = Vector3(x,0,z)
