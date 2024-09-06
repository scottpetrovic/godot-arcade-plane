extends Control

var player: Node3D  # Reference to the player (airplane)
var radar_range: float = 100.0  # Maximum radar range in 3D world units
var radar_radius: float = 50.0  # Radar display radius in pixels

var targets: Array = []
var target_check_interval: float = 1.0  # How often to check for new targets (in seconds)

var font: Font

func _ready():
	check_for_targets_interval()
	
	# Load a font for the North indicator
	font = ThemeDB.fallback_font

func set_player(player_node: Node3D):
	player = player_node

func _process(delta):
	queue_redraw()

func check_for_targets_interval():
	# periodically refresh targets list for radar
	targets = get_tree().get_nodes_in_group("radar_target")
	get_tree().create_timer(target_check_interval).timeout.connect(check_for_targets_interval)

func draw_background_circle():
	# Draw radar background
	draw_circle(Vector2(radar_radius, radar_radius), radar_radius, Color(0, 0.2, 0, 0.5))

func draw_north_indicator():
	var north_angle = -player.rotation.y
	var north_pos = Vector2(0, -radar_radius + 15).rotated(north_angle) + Vector2(radar_radius, radar_radius)
	draw_string(font, north_pos, "N", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.WHITE)

func draw_forward_direction_line():
	# Draw a line indicating the forward direction
	var forward_line = Vector2(0, -radar_radius).rotated(player.rotation.y)
	draw_line(Vector2(radar_radius, radar_radius), Vector2(radar_radius, radar_radius) + forward_line, Color.GREEN, 2.0)


func _draw():
	if not player:
		return

	draw_background_circle()
	draw_forward_direction_line()
	draw_north_indicator()

	for target in targets:
		var target_pos: Vector3 = target.global_transform.origin
		var player_pos: Vector3 = player.global_transform.origin
		
		# Rotate the direction vector by the negative of the player's Y rotation
		var dir: Vector3 = target_pos - player_pos
		dir = dir.rotated(Vector3.UP, -player.rotation.y)
		
		var distance: float = dir.length()
		var angle: float = atan2(dir.x, dir.z)
		var radar_target_pos: Vector2 = calculate_target_position(distance, angle, dir)

		if distance <= radar_range:
			# Draw dot for in-range target
			draw_circle(radar_target_pos, 3, Color.RED)
		else:
			# Draw arrow for out-of-range target
			var edge_pos = radar_target_pos.normalized() * radar_radius + Vector2(radar_radius, radar_radius)
			draw_arrow(edge_pos, angle, Color.RED)

func calculate_target_position(distance: float, angle: float, dir) -> Vector2:
		# Calculate 2D position on radar
		var radar_pos = Vector2(
			sin(angle) * min(distance, radar_range) / radar_range * radar_radius,
			cos(angle) * min(distance, radar_range) / radar_range * radar_radius
		)
		radar_pos += Vector2(radar_radius, radar_radius)
		return radar_pos

func draw_arrow(pos: Vector2, angle: float, color: Color):
	var arrow_size = 10.0
	var points = PackedVector2Array([
		pos,
		pos + Vector2(cos(angle), sin(angle)) * arrow_size,
		pos + Vector2(cos(angle + PI * 0.8), sin(angle + PI * 0.8)) * (arrow_size * 0.5),
		pos + Vector2(cos(angle - PI * 0.8), sin(angle - PI * 0.8)) * (arrow_size * 0.5),
		pos + Vector2(cos(angle), sin(angle)) * arrow_size
	])
	draw_colored_polygon(points, color)
