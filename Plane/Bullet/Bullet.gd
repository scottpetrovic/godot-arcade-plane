extends Area3D
@onready var timer: Timer = $Timer
var speed = 60.0
var LandingParticles = preload("res://Plane/LandingParticles.tscn")

func _ready():
	timer.wait_time = 4.0 # bullet dies after 4 seconds
	$Timer.timeout.connect(queue_free)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta):
	position += -transform.basis.z * speed * delta

func _on_area_entered(area: Area3D):
	if area.name == "Ocean":
		create_impact_effect()

func _on_body_entered(body):
	create_impact_effect()
	
	# affect the body if it has the correct method
	if body.has_method("hit"):
		body.hit()
	queue_free()

func create_impact_effect():
	var particles = LandingParticles.instantiate()
	get_tree().root.add_child(particles)
	particles.global_transform.origin = global_transform.origin
