extends Area3D
@onready var timer: Timer = $Timer
var speed = 60.0


func _ready():
	timer.wait_time = 4.0 # bullet dies after 4 seconds
	$Timer.timeout.connect(queue_free)

func _physics_process(delta):
	position += -transform.basis.z * speed * delta

func _on_body_entered(body):
	if body.has_method("hit"):
		body.hit()
	queue_free()
