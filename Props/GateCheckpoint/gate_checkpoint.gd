extends Area3D

var is_checked: bool = false
@onready var internal_status_bounds_mesh: MeshInstance3D = $InternalStatusBoundsMesh
@onready var cone: MeshInstance3D = $"gate-checkpoint/Cone"
@onready var gate_passed_sound: AudioStreamPlayer2D = $GatePassedSound

@onready var gate_checkpoint: Area3D = $"."


func _ready() -> void:
	self.body_entered.connect(body_enter)
	
func body_enter(body: Node3D) -> void:
	if body is Player && is_checked == false:
		is_checked = true

		# change the color of the gate. we need to make the material
		# unique so it doesn't change all the instances
		var material: Material = internal_status_bounds_mesh.get_active_material(0)
		material = material.duplicate()
		material.albedo_color = Color(0, 1, 0, 0.4)  # Red color (R, G, B)
		internal_status_bounds_mesh.set_surface_override_material(0, material)
		
		# play sound effect
		gate_passed_sound.play()
		
		$FXScaleUpDown.queue_free() # remove existing scaling property
		$"gate-checkpoint".queue_free() # remove rings since are are complete

		
		# tween to scale down completed gate to get it out of the way a bit
		print('should be trying to scale down')
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector3(0.2,0.2,0.2), 1.0)
		
		
		
		
