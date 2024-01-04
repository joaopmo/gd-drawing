extends Control
class_name Crosshair

@export var brush_size := 10.0
@export var brush_color := Color.AQUA

func change_size(size: int) -> void:
	if size >= 5 and size <= 50:
		brush_size = size
		queue_redraw()

func _draw():
	var radius := brush_size / 2.0
	draw_arc(Vector2.ZERO, radius, 0, PI * 2, 32, brush_color, 1.0, true)
	draw_circle(Vector2.ZERO, radius * 0.08, brush_color)


