class_name Bullet
extends Area3D

@onready var timer: Timer = $Timer
var speed = 160.0
var BulletWaterParticles = preload("res://Effects/Particles/BulletHitWaterParticle/BulletHitWaterParticle.tscn")
var BulletObjectHitParticle = preload("res://Effects/Particles/BulletObjectHitParticle/BulletObjectHitParticle.tscn")

@onready var bullet_impact_sound: AudioStreamPlayer3D = $BulletImpactSound

# Add these variables for randomness
var random_deviation = 0.03  # Adjust this value to increase/decrease randomness
var random_direction = Vector3.ZERO

func _ready():
	timer.wait_time = 3.0 # bullet dies after 4 seconds
	$Timer.timeout.connect(queue_free)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Initialize random direction
	random_direction = Vector3(
		randf_range(-1, 1),
		randf_range(-1, 1),
		randf_range(-1, 1)
	).normalized() * random_deviation

func _physics_process(delta):
	# Add random direction to the bullet's trajectory
	position += (-transform.basis.z + random_direction) * speed * delta

func _on_area_entered(area: Area3D):
	if area.name == "Ocean":
		create_water_impact_effect()

	if area.has_method("hit"):
		area.hit()

func _on_body_entered(body):
	create_impact_effect()

	
	# affect the body if it has the correct method
	if body.has_method("hit"):
		body.hit()
	
	# play SFX of bullet collision and wait until it is done
	bullet_impact_sound.play()
	await bullet_impact_sound.finished
	
	queue_free()

func create_water_impact_effect():
	var particles = BulletWaterParticles.instantiate()
	get_tree().root.add_child(particles)
	particles.global_transform.origin = global_transform.origin


func create_impact_effect():
	var particles = BulletObjectHitParticle.instantiate()
	get_tree().root.add_child(particles)
	particles.global_transform.origin = global_transform.origin
