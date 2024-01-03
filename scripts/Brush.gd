extends Node2D

@onready var crosshair_ray_cast: RayCast3D = $"/root/Main/Player/head/CrosshairRayCast"
@onready var draw_viewport = $".."

@export var line_width = 3.0
@export var line_color := Color(1.0, 0.0, 0.0)

var characters = [[]]
# x_min, y_min, x_max, y_max
var bounding_boxes: Array[float] = []

	
func insert_point(mouse_pos: Vector2):
	if bounding_boxes.is_empty():
		bounding_boxes.push_back(mouse_pos.x)
		bounding_boxes.push_back(mouse_pos.y)		
		bounding_boxes.push_back(mouse_pos.x)
		bounding_boxes.push_back(mouse_pos.y)		
			
			
	if mouse_pos.x < bounding_boxes[0]:
		bounding_boxes[0] = mouse_pos.x
	elif mouse_pos.y < bounding_boxes[1]:
		bounding_boxes[1] = mouse_pos.y 
	elif mouse_pos.x > bounding_boxes[2]:
		bounding_boxes[2] = mouse_pos.x 
	elif mouse_pos.y > bounding_boxes[3]:
		bounding_boxes[3] = mouse_pos.y 
	
	if characters.back().is_empty() or not characters.back().back() == mouse_pos:
		characters.back().push_back(mouse_pos)
	
	queue_redraw()
	
func _physics_process(delta):
	if not crosshair_ray_cast.is_colliding():
		return 
		
	if Input.is_action_just_pressed("draw"):
		# ML logic
		characters = [[]]
		bounding_boxes.clear()
	
	if Input.is_action_just_pressed("ui_left_click") and not characters.back().is_empty():
		characters.push_back([])
		
	if Input.is_action_pressed("ui_left_click"):
		var position = crosshair_ray_cast.get_collision_point()
		var normal = crosshair_ray_cast.get_collision_normal()
		var uv = LevelUVPosition.get_uv_coords(position, normal, true)
		if uv:
			insert_point(uv * Vector2(draw_viewport.size))

		
func _draw():
	for line in characters:
		if line.size() >= 2:
			draw_polyline(line, line_color, line_width, true)
		elif line.size() == 1:
			draw_circle(line.back(), line_width, line_color)
