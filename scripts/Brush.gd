extends Node2D

@onready var crosshair_ray_cast: RayCast3D = $"/root/Main/Player/head/CrosshairRayCast"
@onready var draw_viewport = $".."

@export var line_width := 10.0
@export var line_color := Color(1.0, 0.0, 0.0)

signal drawing_start;
signal drawing_stop;

var characters = [[]]
var points : Array[Vector2] = []

func insert_point(mouse_pos: Vector2):
	if points.is_empty() or not points.back().is_equal_approx(mouse_pos):
		points.push_back(mouse_pos)
	queue_redraw()
	
func _process(delta):
	if not crosshair_ray_cast.is_colliding():
		points.clear()
		return 
	
	if Input.is_action_just_pressed("ui_left_click"):
		drawing_start.emit()
		points.clear()
			
	if Input.is_action_just_released("ui_left_click"):
		drawing_stop.emit()
		
	if Input.is_action_pressed("ui_left_click"):
		var position = crosshair_ray_cast.get_collision_point()
		var normal = crosshair_ray_cast.get_collision_normal()
		var uv = LevelUVPosition.get_uv_coords(position, normal, true)
		if uv:
			insert_point(uv * Vector2(draw_viewport.size))

		
func _draw():
	if points.size() >= 2:
		draw_polyline(points, line_color, line_width, true)
	elif points.size() == 1:
		draw_circle(points.back(), line_width * 0.5, line_color)



func _on_player_brush_size_change(size : float):
	points.clear()
	line_width = size


func _on_player_brush_color_change(color : Color):
	points.clear()
	line_color = color
	
