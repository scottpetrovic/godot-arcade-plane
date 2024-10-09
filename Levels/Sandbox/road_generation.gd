# RoadGenerator.gd
extends Node3D

var road_width = 8.0
var road_height = 0.3

func generate_roads(city_size: int, block_size: float, ground_height_offset: float):
	var road_material = StandardMaterial3D.new()
	road_material.albedo_color = Color(0.2, 0.2, 0.2)  # Dark gray for asphalt

	# Horizontal roads
	for z in range(city_size + 1):
		var road = CSGBox3D.new()
		road.size = Vector3(block_size * city_size, road_height, road_width)
		road.position = Vector3(
			(block_size * city_size) / 2,  # Center of the city horizontally
			ground_height_offset + road_height / 2,
			z * block_size - road_width # Centered on block boundary
		)
		road.material = road_material
		add_child(road)

	# Vertical roads
	for x in range(city_size + 1):
		var road = CSGBox3D.new()
		road.size = Vector3(road_width, road_height, block_size * city_size)
		road.position = Vector3(
			x * block_size - road_width,  # Centered on block boundary
			ground_height_offset + road_height / 2,
			(block_size * city_size) / 2  # Center of the city vertically
		)
		road.material = road_material
		add_child(road)

	# Intersections (to cover any gaps)
	for x in range(city_size + 1):
		for z in range(city_size + 1):
			var intersection = CSGBox3D
