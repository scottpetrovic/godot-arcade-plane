extends Node3D

@onready var shoot_timer: Timer = $ShootTimer
@onready var bullet_spawn_point: Marker3D = $"../BulletSpawnPoint"

var Bullet = preload("res://Plane/Bullet/Bullet.tscn")

var can_shoot = true
var shoot_delay = 0.3

func _ready():
	shoot_timer.wait_time = shoot_delay
	shoot_timer.timeout.connect(reset_can_shoot)

func shoot():
	if can_shoot:
		can_shoot = false
		shoot_timer.start()

		var bullet_instance: Area3D = Bullet.instantiate()
		get_tree().root.add_child(bullet_instance)
		bullet_instance.global_transform = bullet_spawn_point.global_transform

func reset_can_shoot():
	can_shoot = true