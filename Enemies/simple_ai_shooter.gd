extends Node

@onready var shoot_timer: Timer = $ShootTimer

# make sure to check inspector in case this was overwritten
@export var shoot_delay = 0.3
@export var Bullet = preload("res://Props/Bullet/Bullet.tscn")
@export var attack_range = 25.0  # How close the enemy needs to be to attack (for future use)
@export var bullet_spawn_point: Marker3D
var rng = RandomNumberGenerator.new()

var can_shoot = true

func _ready():
	rng.randomize()  # Initialize the random number generator
	
	shoot_timer.wait_time = shoot_delay
	shoot_timer.timeout.connect(reset_can_shoot)

func shoot():
	if can_shoot:
		can_shoot = false
		
		# add randomness so multiple instances won't shoot
		# at same time
		var random_delay = rng.randf_range(shoot_delay*0.6, shoot_delay*1.3)
		shoot_timer.start(random_delay)

		var bullet_instance: Area3D = Bullet.instantiate()
		get_tree().root.add_child(bullet_instance)
		bullet_instance.global_transform = bullet_spawn_point.global_transform

func reset_can_shoot():
	can_shoot = true
