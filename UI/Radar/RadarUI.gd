extends Control

var player: Node3D  # Reference to the player (airplane)
var radar_range: float = 100.0  # Maximum radar range in 3D world units
var radar_radius: float = 50.0  # Radar display radius in pixels
var player_dot_radius: float = 3.0  # Radius of the player's dot on the radar

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

	# small stroke for border. Maybe use fancier UI element for this later
	var stroke_color = Color(1.0, 1.0, 1.0, 1)  # Adjust color as needed
	var stroke_width = 5.0  # Adjust width as needed
	var center = Vector2(radar_radius, radar_radius)
	var start_angle = 0
	var end_angle = TAU #  PI * 2
	draw_arc(center, radar_radius, start_angle, end_angle, 64, stroke_color, stroke_width)

func draw_north_indicator():
	var text_content = "N"
	var font_size = 16
	var north_angle = player.rotation.y
	var dist_offset = 3
	var north_pos: Vector2 = Vector2(0, radar_radius+dist_offset).rotated(north_angle) + Vector2(radar_radius, radar_radius)
	north_pos += Vector2(-font_size*0.5, font_size*0.5)
	
		# draw string outline for visibility
	draw_string_outline(font, north_pos, text_content, HORIZONTAL_ALIGNMENT_CENTER, 16, font_size,12,Color.BLACK )
	
	draw_string(font, north_pos, text_content, HORIZONTAL_ALIGNMENT_CENTER, 16, font_size, Color.WHITE)


func draw_forward_direction_line():
	# Draw a line indicating the forward direction
	var forward_line = Vector2(0, -radar_radius).rotated(player.rotation.y)
	draw_line(Vector2(radar_radius, radar_radius), Vector2(radar_radius, radar_radius) + forward_line, Color.GREEN, 2.0)

func draw_player_dot():
	var center = Vector2(radar_radius, radar_radius)
	draw_circle(center, player_dot_radius, Color.WHITE)


func _draw():
	if not player:
		return

	draw_background_circle()
	draw_north_indicator()
	draw_player_dot()

	for target in targets:
		
		# only show target if it is not completed
		if target.has_method("is_completed") && target.is_completed():
			# our target has been finished, don't show on radar
			continue
		
		var target_pos_2d: Vector2 = Vector2(target.global_position.x, target.global_position.z)
		var player_pos_2d: Vector2 = Vector2(player.global_position.x, player.global_position.z)
		
		# Rotate the direction vector by the negative of the player's Y rotation
		var dir: Vector2 = target_pos_2d - player_pos_2d
		dir = dir.rotated(player.rotation.y)
		
		var distance: float = dir.length()
		var angle = dir.angle()
		var radar_target_pos = dir.normalized() * min(distance, radar_range) / radar_range * radar_radius 
		radar_target_pos += Vector2(radar_radius, radar_radius)

		if distance <= radar_range:
			# Draw dot for in-range target
			draw_circle(radar_target_pos, 3, Color.RED)
		else:
			# Draw arrow for out-of-range target
			var outside_indicator_dist = radar_radius * 1.2 # a bit outside radar circle
			var centered = Vector2(radar_radius, radar_radius)
			var edge_pos = dir.normalized() * outside_indicator_dist + centered
			draw_arrow(edge_pos, angle, Color.RED)

func draw_arrow(pos: Vector2, angle: float, color: Color):
	var triangle_size = 8.0  # Size of the triangle
	var half_size = triangle_size * 0.8
	
	angle += PI # flips triangle upside down

	# Calculate the three points of the equilateral triangle
	var point1 = pos + Vector2.RIGHT.rotated(angle) * triangle_size
	var point2 = pos + Vector2.RIGHT.rotated(angle + 2*PI/3) * half_size
	var point3 = pos + Vector2.RIGHT.rotated(angle - 2*PI/3) * half_size

	var points = PackedVector2Array([point1, point2, point3])
	draw_colored_polygon(points, color)
