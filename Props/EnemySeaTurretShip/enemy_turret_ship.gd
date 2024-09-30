extends CharacterBody3D
signal enemy_died(enemy)

var health = 8

func hit() -> void:
	health -= 1
	
	if health <= 0:
		die()

func die():
	emit_signal("enemy_died", self)
	GameManager.create_explosion(self.global_position, 30)
	# do small screen shake to help with effect
	# strenth, duration
	var main_camera: Camera3D = get_viewport().get_camera_3d()
	main_camera.get_node("ScreenShake").camera_shake_impulse(.1, 1.6)
	
	queue_free()  # The enemy removes itself from the scene
