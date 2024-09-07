extends Node3D

@onready var shoot_timer: Timer = $ShootTimer
var Bullet = preload("res://Plane/Bullet/Bullet.tscn")
@onready var bullet_sound: AudioStreamPlayer2D = $BulletSound

var can_shoot = true
var shoot_delay = 0.3

var MuzzleFlash = preload("res://Plane/MuzzleFlash/MuzzleFlash.tscn")
@onready var muzzle_left = $MuzzleLeft
@onready var muzzle_right = $MuzzleRight

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

	bullet_left.global_transform = muzzle_left.global_transform
	bullet_right.global_transform = muzzle_right.global_transform

	create_muzzle_flash(muzzle_left)
	create_muzzle_flash(muzzle_right)

func create_muzzle_flash(muzzle):
	var flash = MuzzleFlash.instantiate()
	muzzle.add_child(flash)
	flash.global_transform.origin = muzzle.global_transform.origin

func reset_can_shoot():
	can_shoot = true
