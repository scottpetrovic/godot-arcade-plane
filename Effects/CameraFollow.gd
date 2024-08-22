extends Camera3D

## The factor to use for asymptotical translation lerping.
## If 0, the camera will stop moving. If 1, the camera will move instantly.
@export_range(0, 1, 0.01) var translate_speed := 0.50

## The factor to use for asymptotical rotation lerping.
## If 0, the camera will stop rotating. If 1, the camera will rotate instantly.
@export_range(0, 1, 0.001) var rotate_speed := 0.35

## The node to target.
## Can optionally be a Camera3D to support smooth FOV and Z near/far plane distance changes.
@export var target: Node3D

@export var should_look_at_target: bool = false

func _process(delta: float) -> void:
	if not target is Node3D:
		return

	var translate_factor := 1 - pow(1 - translate_speed, delta * 3.45233)
	var rotate_factor := 1 - pow(1 - rotate_speed, delta * 3.45233)
	var target_xform := target.get_global_transform()
	
	# Interpolate the origin and basis separately so we can have different translation and rotation
	# interpolation speeds.
	var local_transform_only_origin := Transform3D(Basis(), get_global_transform().origin)
	var local_transform_only_basis := Transform3D(get_global_transform().basis, Vector3())
	local_transform_only_origin = local_transform_only_origin.interpolate_with(target_xform, translate_factor)
	local_transform_only_basis = local_transform_only_basis.interpolate_with(target_xform, rotate_factor)
	set_global_transform(Transform3D(local_transform_only_basis.basis, local_transform_only_origin.origin))

	if should_look_at_target:
		look_at(target.global_transform.origin, Vector3(0, 1, 0))
