extends Area3D

var is_checked: bool = false
@onready var internal_status_bounds_mesh: MeshInstance3D = $InternalStatusBoundsMesh
@onready var gate_passed_sound: AudioStreamPlayer2D = $GatePassedSound



func _ready() -> void:
	self.body_entered.connect(body_enter)
	
func body_enter(body: Node3D) -> void:
	if body.name == "Airplane" || body.name == "PlayerSkydiver":
		is_checked = true

		# change the color of the gate. we need to make the material
		# unique so it doesn't change all the instances
		var material: Material = internal_status_bounds_mesh.get_active_material(0)
		material = material.duplicate()
		internal_status_bounds_mesh.set_surface_override_material(0, material)
		material.albedo_color = Color(0, 1, 0, 0.4)  # Red color (R, G, B)
		
		# play sound effect
		gate_passed_sound.play()
		
		
