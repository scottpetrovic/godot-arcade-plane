extends HBoxContainer

@onready var spawn_1_button: Button = $SpawnEnemiesLayout/Spawn1Button
@onready var spawn_2_button: Button = $SpawnEnemiesLayout/Spawn2Button
@onready var spawn_3_button: Button = $SpawnEnemiesLayout/Spawn3Button
@onready var spawn_4_button: Button = $SpawnEnemiesLayout/Spawn4Button
@onready var spawn_5_button: Button = $SpawnEnemiesLayout/Spawn5Button
@onready var spawn_6_button: Button = $SpawnEnemiesLayout/Spawn6Button

@onready var reload_button: Button = $OtherButtonsLayout/ReloadButton
@onready var gun_mode_button: CheckButton = $OtherButtonsLayout/GunModeButton
@onready var shoot_delay_slider: HSlider = $OtherButtonsLayout/HBoxContainer/ShootDelaySlider



# objects to create
@export var air_basic_enemy: PackedScene
@export var air_scout_enemy: PackedScene
@export var air_frigate_enemy: PackedScene
@export var sea_ship: PackedScene
@export var turret_block: PackedScene
@export var kaiju: PackedScene



func _ready() -> void:
	spawn_1_button.pressed.connect(_spawn_1_press)
	spawn_2_button.pressed.connect(_spawn_2_press)
	spawn_3_button.pressed.connect(_spawn_3_press)
	spawn_4_button.pressed.connect(_spawn_4_press)
	spawn_5_button.pressed.connect(_spawn_5_press)
	spawn_6_button.pressed.connect(_spawn_6_press)
	
	gun_mode_button.toggled.connect(_gun_mode_toggle)
	shoot_delay_slider.drag_ended.connect(_gun_shoot_delay_changed)
	
	reload_button.pressed.connect(reload_scene)

func _gun_shoot_delay_changed(_change_status: bool) -> void:
	#print(shoot_delay_slider.value)
	GameManager.curent_player_shoot_delay_time = shoot_delay_slider.value

func _gun_mode_toggle(toggled_status) -> void:
	
	# if yes, we are going to turn on our double shooters
	if toggled_status:
		GameManager.current_player_shoot_mode = GameManager.ShootType.DOUBLE
	else:
		GameManager.current_player_shoot_mode = GameManager.ShootType.SINGLE

func reload_scene() -> void:
	var current_scene_path = get_tree().current_scene.scene_file_path
	GameManager.current_level_remaining_enemies = 0
	get_tree().change_scene_to_file(current_scene_path)

func _spawn_1_press() -> void:
	var enemy = air_basic_enemy.instantiate()
	var pos: Vector3 = find_random_position(enemy, true)
	GameManager.create_enemy(enemy, pos)


func _spawn_2_press() -> void:
	var enemy = air_scout_enemy.instantiate()
	var pos: Vector3 = find_random_position(enemy, true)
	GameManager.create_enemy(enemy, pos)


func _spawn_3_press() -> void:
	var enemy = sea_ship.instantiate()
	var pos: Vector3 = find_random_position(enemy, false)
	GameManager.create_enemy(enemy, pos)

func _spawn_4_press() -> void:
	var enemy = air_frigate_enemy.instantiate()
	var pos: Vector3 = find_random_position(enemy, true)
	print(pos)
	GameManager.create_enemy(enemy, pos)


func _spawn_5_press() -> void:
	var enemy = turret_block.instantiate()
	var pos: Vector3 = find_random_position(enemy, false)
	GameManager.create_enemy(enemy, pos)

func _spawn_6_press() -> void:
	var enemy = kaiju.instantiate()
	var pos: Vector3 = find_random_position(enemy, false)
	GameManager.create_enemy(enemy, pos)

func find_random_position(object: Node3D, is_in_air: bool = true) -> Vector3:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
		
	var x = rng.randf_range(-40.0, 40.0)
	var y = rng.randf_range(20.0, 30.0)
	var z = rng.randf_range(-30.0, -50.0)

	if is_in_air:
		return Vector3(x,y,z)

	return Vector3(x,0,z)
