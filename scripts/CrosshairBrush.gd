extends Node2D

@onready var crosshair_viewport: SubViewport = $".."

var brush_size := 10.0
var brush_color := Color.AQUA
var is_drawing := false

var center : Vector2

func logBase(value, base):
	return log(value) / log(base)
		
func _ready():
	center = Vector2(crosshair_viewport.size) / 2.0

func _draw():
	var radius := brush_size + brush_size * 0.4
	var color := Color.AQUA if is_drawing else brush_color
	draw_arc(center, radius, 0, PI * 2, 32, color, 1.0, true)
	draw_circle(center, radius * 0.08, color)


func _on_player_crosshair_ray_cast_start(_crosshair_ray_cast):
	queue_redraw()


func _on_player_brush_size_change(size: float):
	brush_size = size
	queue_redraw()

func _on_player_brush_color_change(color):
	brush_color = color
	queue_redraw()

func _on_player_drawing_start(crosshair_ray_cast):
	is_drawing = true

func _on_player_drawing_stop(crosshair_ray_cast):
	is_drawing = false



