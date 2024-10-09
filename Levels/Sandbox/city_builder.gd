extends Node3D

@export var city_size: int = 10
@export var block_size: float = 30.0
@export var road_width: float = 18.0
@export var min_building_height: float = 5.0
@export var max_building_height: float = 30.0
@export var height_variation_step: float = 2.5
@export var ground_height_offset: float = 0.1
@export var generation_seed: int = 0
@export var building_margin: float = 0.5  # Margin between buildings

@onready var road_generation: Node3D = $"../RoadGeneration"


var rng: RandomNumberGenerator
var buildings: Array = []

enum BuildingType { CUBE, CYLINDER, PYRAMID, L_SHAPE, U_SHAPE, SKYSCRAPER }

func _ready():
	generate_cityscape()
	road_generation.generate_roads(city_size, block_size, ground_height_offset)
 

func generate_cityscape():
	rng = RandomNumberGenerator.new()
	rng.seed = generation_seed if generation_seed != 0 else randi()
	print("Using seed: ", rng.seed)
	
	var building_size = block_size - road_width - (building_margin * 2)
	
	for x in range(city_size):
		for z in range(city_size):
			var pos_x = x * block_size
			var pos_z = z * block_size
			
			var height = generate_building_height()
			var building_type = choose_building_type()
			var building = create_building(Vector3(block_size - road_width, height, block_size - road_width), building_type)
			
			# Add small random offset to position
			var offset_x = rng.randf_range(-0.5, 0.5)
			var offset_z = rng.randf_range(-0.5, 0.5)
			
			building.position = Vector3(
				pos_x + road_width / 2 + offset_x, 
				height / 2 + ground_height_offset, 
				pos_z + road_width / 2 + offset_z
			)
			
			add_child(building)

func choose_building_type() -> int:
	var roll = rng.randf()
	if roll < 0.6:
		return BuildingType.CUBE
	elif roll < 0.7:
		return BuildingType.CYLINDER
	elif roll < 0.8:
		return BuildingType.PYRAMID
	elif roll < 0.9:
		return BuildingType.L_SHAPE
	elif roll < 0.95:
		return BuildingType.U_SHAPE
	else:
		return BuildingType.SKYSCRAPER

func create_building(size: Vector3, type: int) -> Node3D:
	match type:
		BuildingType.CUBE:
			return create_cube_building(size)
		BuildingType.CYLINDER:
			return create_cylinder_building(size)
		BuildingType.PYRAMID:
			return create_pyramid_building(size)
		BuildingType.L_SHAPE:
			return create_l_shape_building(size)
		BuildingType.U_SHAPE:
			return create_u_shape_building(size)
		BuildingType.SKYSCRAPER:
			return create_skyscraper(size)
	return null

func create_cube_building(size: Vector3) -> Node3D:
	var building = Node3D.new()
	
	var main_part = CSGBox3D.new()
	main_part.size = size
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(rng.randf(), rng.randf(), rng.randf())
	main_part.material = material
	
	building.add_child(main_part)
	
	# Add A/C unit with 70% probability
	if rng.randf() < 0.7:
		var ac_unit = create_ac_unit(size)
		building.add_child(ac_unit)
	
	return building

func create_cylinder_building(size: Vector3) -> StaticBody3D:
	var static_body = StaticBody3D.new()
	var mesh_instance = MeshInstance3D.new()
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.top_radius = min(size.x, size.z) / 2
	cylinder_mesh.bottom_radius = cylinder_mesh.top_radius
	cylinder_mesh.height = size.y
	mesh_instance.mesh = cylinder_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(rng.randf(), rng.randf(), rng.randf())
	mesh_instance.material_override = material
	
	var collision_shape = CollisionShape3D.new()
	var cylinder_shape = CylinderShape3D.new()
	cylinder_shape.radius = cylinder_mesh.top_radius
	cylinder_shape.height = size.y
	collision_shape.shape = cylinder_shape
	
	static_body.add_child(mesh_instance)
	static_body.add_child(collision_shape)
	return static_body

func create_pyramid_building(size: Vector3) -> StaticBody3D:
	var static_body = StaticBody3D.new()
	var mesh_instance = MeshInstance3D.new()
	var prism_mesh = PrismMesh.new()
	prism_mesh.size = size
	mesh_instance.mesh = prism_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(rng.randf(), rng.randf(), rng.randf())
	mesh_instance.material_override = material
	
	var collision_shape = CollisionShape3D.new()
	var convex_shape = ConvexPolygonShape3D.new()
	var points = [
		Vector3(-size.x/2, -size.y/2, -size.z/2),
		Vector3(size.x/2, -size.y/2, -size.z/2),
		Vector3(size.x/2, -size.y/2, size.z/2),
		Vector3(-size.x/2, -size.y/2, size.z/2),
		Vector3(0, size.y/2, 0)
	]
	convex_shape.points = points
	collision_shape.shape = convex_shape
	
	static_body.add_child(mesh_instance)
	static_body.add_child(collision_shape)
	return static_body

func create_l_shape_building(size: Vector3) -> CSGCombiner3D:
	var building = CSGCombiner3D.new()
	
	# Main part
	var main_part = CSGBox3D.new()
	main_part.size = size
	building.add_child(main_part)
	
	# Secondary part
	var secondary_part = CSGBox3D.new()
	secondary_part.size = Vector3(size.x / 2, size.y, size.z / 2)
	secondary_part.position = Vector3(size.x / 4, 0, size.z / 4)
	secondary_part.operation = CSGShape3D.OPERATION_SUBTRACTION
	building.add_child(secondary_part)
	
	# Add material to both parts
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(rng.randf(), rng.randf(), rng.randf())
	main_part.material = material
	secondary_part.material = material
	
	return building

func create_u_shape_building(size: Vector3) -> CSGCombiner3D:
	var building = CSGCombiner3D.new()
	
	# Main part
	var main_part = CSGBox3D.new()
	main_part.size = size
	building.add_child(main_part)
	
	# Cut out the center to create U shape
	var cutout = CSGBox3D.new()
	cutout.size = Vector3(size.x * 0.6, size.y + 0.1, size.z * 0.6)  # Slightly taller to ensure complete cut
	cutout.position = Vector3(0, 0, size.z * 0.2)
	cutout.operation = CSGShape3D.OPERATION_SUBTRACTION
	building.add_child(cutout)
	
	# Add material to the main part (cutout doesn't need material as it's subtracted)
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(rng.randf(), rng.randf(), rng.randf())
	main_part.material = material
	
	return building

func create_skyscraper(size: Vector3) -> Node3D:
	var skyscraper = Node3D.new()
	
	var main_part = CSGBox3D.new()
	main_part.size = Vector3(size.x, size.y * 2, size.z)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(rng.randf(), rng.randf(), rng.randf())
	main_part.material = material
	
	skyscraper.add_child(main_part)
	
	# Add A/C unit
	var ac_unit = create_ac_unit(main_part.size)
	skyscraper.add_child(ac_unit)
	
	# Add antenna
	var antenna = CSGCylinder3D.new()
	antenna.radius = size.x * 0.05
	antenna.height = size.y * 0.5
	antenna.position = Vector3(0, size.y + antenna.height / 2, 0)
	
	var antenna_material = StandardMaterial3D.new()
	antenna_material.albedo_color = Color(0.4, 0.4, 0.4)  # Dark gray color
	antenna.material = antenna_material
	
	skyscraper.add_child(antenna)
	
	return skyscraper

func replace_with_cluster(building):
	var num_buildings = rng.randi_range(2, 3)
	var original_size = building["size"]
	var cluster_size = Vector2(original_size.x, original_size.z)
	var positions = generate_cluster_positions(num_buildings, cluster_size)
	
	for pos in positions:
		var size = Vector3(pos.size.x, generate_building_height(), pos.size.y)
		var building_type = choose_building_type()
		var new_building = create_building(size, building_type)
		var world_pos = building["node"].position
		new_building.position = Vector3(world_pos.x + pos.position.x - cluster_size.x/2, 
										size.y/2 + ground_height_offset, 
										world_pos.z + pos.position.y - cluster_size.y/2)
		buildings.append({"node": new_building, "position": building["position"], "size": size})

func generate_cluster_positions(num_buildings: int, cluster_size: Vector2) -> Array:
	var positions = []
	var min_building_size = 5.0
	
	for i in range(num_buildings):
		var size = Vector2(
			rng.randf_range(min_building_size, cluster_size.x - min_building_size),
			rng.randf_range(min_building_size, cluster_size.y - min_building_size)
		)
		var position = Vector2(
			rng.randf_range(0, cluster_size.x - size.x),
			rng.randf_range(0, cluster_size.y - size.y)
		)
		positions.append({"position": position, "size": size})
	
	return positions

func create_ac_unit(building_size: Vector3) -> CSGBox3D:
	var ac_unit = CSGBox3D.new()
	var ac_size = Vector3(
		building_size.x * 0.3, 
		building_size.y * 0.1, 
		building_size.z * 0.3
	)
	ac_unit.size = ac_size
	
	# Position the A/C unit on top of the building, slightly off-center
	ac_unit.position = Vector3(
		rng.randf_range(-building_size.x * 0.2, building_size.x * 0.2),
		building_size.y / 2 + ac_size.y / 2,
		rng.randf_range(-building_size.z * 0.2, building_size.z * 0.2)
	)
	
	# Give the A/C unit a distinct color
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.7, 0.7, 0.7)  # Light gray color
	ac_unit.material = material
	
	return ac_unit


func generate_building_height() -> float:
	var base_height = rng.randf_range(min_building_height, max_building_height)
	var variation = rng.randf_range(-3, 3) * height_variation_step
	return clamp(base_height + variation, min_building_height, max_building_height)

func add_special_structures():
	# Add a tall landmark building
	var landmark_size = Vector3(block_size - road_width, max_building_height * 2, block_size - road_width)
	var landmark = create_skyscraper(landmark_size)
	var landmark_x = city_size * block_size * 0.75
	var landmark_z = city_size * block_size * 0.75
	landmark.position = Vector3(landmark_x, landmark_size.y / 2 + ground_height_offset, landmark_z)
	add_child(landmark)

func clear_cityscape():
	for child in get_children():
		child.queue_free()
	buildings.clear()

func regenerate_cityscape():
	clear_cityscape()
	generate_cityscape()

func regenerate_with_seed(new_seed: int):
	generation_seed = new_seed
	regenerate_cityscape()
