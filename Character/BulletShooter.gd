extends Node3D

@onready var shoot_timer: Timer = $ShootTimer
@onready var bullet_sound: AudioStreamPlayer2D = $BulletSound
@onready var muzzle_left = $MuzzleLeft
@onready var muzzle_right = $MuzzleRight
@onready var muzzle_center: Marker3D = $MuzzleCenter

var MuzzleFlash = preload("res://Effects/Particles/MuzzleFlash/MuzzleFlash.tscn")
var BulletCasing = preload("res://Props/BulletCasing/BulletCasing.tscn")
var Bullet = preload("res://Props/Bullet/Bullet.tscn")

var can_shoot = true

func _ready():
	shoot_timer.wait_time = GameManager.curent_player_shoot_delay_time
	shoot_timer.timeout.connect(reset_can_shoot)

func _process(_delta):
	if Input.is_action_pressed("plane_shoot") and can_shoot:
		shoot()

func shoot():
	can_shoot = false
	# specifying shoot timer again in case we change on debug UI
	shoot_timer.start(GameManager.curent_player_shoot_delay_time)

	match GameManager.current_player_shoot_mode:
		GameManager.ShootType.SINGLE:
			var bullet_center = Bullet.instantiate()
			get_tree().root.add_child(bullet_center)
			bullet_center.global_transform = muzzle_center.global_transform
			create_muzzle_flash(muzzle_center)
			eject_casing(muzzle_center)
		GameManager.ShootType.DOUBLE:
			var bullet_left = Bullet.instantiate()
			var bullet_right = Bullet.instantiate()
			get_tree().root.add_child(bullet_left)
			get_tree().root.add_child(bullet_right)
			bullet_left.global_transform = muzzle_left.global_transform
			bullet_right.global_transform = muzzle_right.global_transform
			create_muzzle_flash(muzzle_left)
			create_muzzle_flash(muzzle_right)
			eject_casing(muzzle_left)
			eject_casing(muzzle_right)
	
	# sound effect
	var random_pitch = minf(randf() + 0.5, 1.0) #constrain to 0.5 -> 1.0
	bullet_sound.pitch_scale = random_pitch
	bullet_sound.play() # play sfx

func eject_casing(muzzle):
	var casing = BulletCasing.instantiate()
	get_tree().root.add_child(casing)
	casing.global_transform = muzzle.global_transform
	casing.global_transform.origin += muzzle.global_transform.basis.x * 0.2  # Offset to the side

	# Apply an impulse to eject the casing
	var ejection_dir = muzzle.global_transform.basis.x + muzzle.global_transform.basis.y * 0.5
	casing.apply_impulse(ejection_dir.normalized() * 2)


func create_muzzle_flash(muzzle):
	var flash = MuzzleFlash.instantiate()
	muzzle.add_child(flash)
	flash.global_transform.origin = muzzle.global_transform.origin

func reset_can_shoot():
	can_shoot = true
