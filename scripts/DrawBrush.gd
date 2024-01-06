extends Node2D

@onready var draw_viewport = $".."

var brush_size := 10.0
var brush_color := Color.RED

var points : Array[Vector2] = []

func insert_point(mouse_pos: Vector2):
	if points.is_empty() or not points.back().is_equal_approx(mouse_pos):
		points.push_back(mouse_pos)
	queue_redraw()
	
func _draw():
	if points.size() >= 2:
		draw_polyline(points, brush_color, brush_size, true)
	elif points.size() == 1:
		draw_circle(points.back(), brush_size * 0.5, brush_color)
		

func _on_player_brush_size_change(size : float):
	brush_size = size
	queue_redraw()


func _on_player_brush_color_change(color : Color):
	brush_color = color
	queue_redraw()
	
func _on_player_drawing_start(_crosshair_ray_cast):
	points.clear()

func _on_player_drawing_stop(_crosshair_ray_cast):
	points.clear()

func _on_player_drawing_input(crosshair_ray_cast: RayCast3D):
	var point = crosshair_ray_cast.get_collision_point()
	var normal = crosshair_ray_cast.get_collision_normal()
	var uv = LevelUVPosition.get_uv_coords(point, normal, true)
	if uv:
		insert_point(uv * Vector2(draw_viewport.size))
