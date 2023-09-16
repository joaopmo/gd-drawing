extends Node2D

var characters: Array[PackedVector2Array] = [PackedVector2Array()]

func _process(_delta):
	if Input.is_action_just_pressed("ui_ctrl"):
		characters = [PackedVector2Array()]
	
	if Input.is_action_just_pressed("ui_left_click") and characters.back().size() != 0:
		characters.push_back(PackedVector2Array())
		
	if Input.is_action_pressed("ui_ctrl") and Input.is_action_pressed("ui_left_click"):
		insert_point()	

	if Input.is_action_just_released("ui_ctrl"):
		print(characters)
		
	queue_redraw()
	
		
		
func _draw():
	for line in characters:
		for p in range(1, line.size()):
			draw_line(line[p-1], line[p], Color(1.0, 0.0, 0.0), 3.0)
		

func insert_point():
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	characters.back().push_back(mouse_pos)
