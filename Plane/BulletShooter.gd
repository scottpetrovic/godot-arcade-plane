extends Node3D

@onready var shoot_timer: Timer = $ShootTimer
var Bullet = preload("res://Plane/Bullet/Bullet.tscn")
@onready var bullet_sound: AudioStreamPlayer2D = $BulletSound

var can_shoot = true
var shoot_delay = 0.3

func _ready():
	shoot_timer.wait_time = shoot_delay
	shoot_timer.timeout.connect(reset_can_shoot)

func _process(_delta):
	if Input.is_action_pressed("plane_shoot") and can_shoot:
		shoot()

func shoot():
	can_shoot = false
	shoot_timer.start()

	var bullet_left = Bullet.instantiate()
	var bullet_right = Bullet.instantiate()
	
	var random_pitch = minf(randf() + 0.5, 1.0) #constrain to 0.5 -> 1.0
	bullet_sound.pitch_scale = random_pitch
	bullet_sound.play() # play sfx

	get_tree().root.add_child(bullet_left)
	get_tree().root.add_child(bullet_right)

	bullet_left.global_transform = $MuzzleLeft.global_transform
	bullet_right.global_transform = $MuzzleRight.global_transform

func reset_can_shoot():
	can_shoot = true
