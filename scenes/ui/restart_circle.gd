extends Control

const CIRCLE_RADIUS: float = 40.0
const CIRCLE_WIDTH: float = 14.0
const BG_COLOR: Color = Color(0.2, 0.2, 0.2, 0.8)
const FILL_COLOR: Color = Color(1.0, 0.3, 0.3, 1.0)


func _draw():
	var center = size / 2.0
	var parent = get_parent()
	var progress = parent.hold_progress if parent else 0.0

	# Tło koła (szare)
	draw_arc(center, CIRCLE_RADIUS, 0, TAU, 64, BG_COLOR, CIRCLE_WIDTH, true)

	# Wypełnienie (czerwone) - od góry zgodnie z ruchem wskazówek
	if progress > 0:
		var start_angle = -PI / 2  # Start od góry
		var end_angle = start_angle + (progress * TAU)
		draw_arc(center, CIRCLE_RADIUS, start_angle, end_angle, 64, FILL_COLOR, CIRCLE_WIDTH, true)

	# Ikona "R" w środku
	draw_string(ThemeDB.fallback_font, center + Vector2(-8, 8), "R", HORIZONTAL_ALIGNMENT_CENTER, -1, 24, FILL_COLOR if progress > 0 else BG_COLOR)
