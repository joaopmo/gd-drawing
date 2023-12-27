extends Node2D

@onready var server : WebSocketServer = $WebSocketServer
@export var line_width = 3.0
@export var line_color := Color(1.0, 0.0, 0.0)

var PORT = 8002
var thread: Thread

var characters = [[]]
# x_min, y_min, x_max, y_max
var bounding_boxes: Array[float] = []

func _ready():
	var err = server.listen(PORT)
	if err == OK:
		print("PORT: %s" % PORT)
		thread  = Thread.new()
		thread.start(call_py_on_thread.bind(PORT))
	else:
		print("Error listening on port %s" % PORT)



func _process(_delta):
	if Input.is_action_just_pressed("ui_ctrl"):
		characters = [[]]
		bounding_boxes.clear()
	
	if Input.is_action_just_pressed("ui_left_click") and not characters.back().is_empty():
		characters.push_back([])
		
	if Input.is_action_pressed("ui_ctrl") and Input.is_action_pressed("ui_left_click"):
		insert_point()	

	if Input.is_action_just_released("ui_ctrl"):
		server.send(0, JSON.stringify({"type": "char", "data": characters.map(map_vector_arr), "bbox": bounding_boxes}))
	
	
		
	queue_redraw()
	
		
		
func _draw():
	for line in characters:
		if line.size() >= 2:
			draw_polyline(line, line_color, line_width, true)
		elif line.size() == 1:
			draw_circle(line.back(), line_width, line_color)
			
			
func call_py_on_thread(port):
	print("Thread call ", OS.get_executable_path())
	var output = []
#	var status = OS.execute("sh", ["python/linux.sh", port], output, true)
#	if status != 0:
#		print("Error runing python script")
	print("Python output ", output)

func stop_py():
	print("close")
	server.stop()
	thread.wait_to_finish()
	
func map_vector_arr(vector_arr):
	return vector_arr.map(func(p: Vector2): return [p.x, p.y])
	
			
		
func insert_point():
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	
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
	
	
	if characters.back().is_empty() or not characters.back().back().is_equal_approx(mouse_pos):
		characters.back().push_back(mouse_pos)


func _exit_tree():
	stop_py()
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		stop_py()
		get_tree().quit() # default behavior


func _on_web_socket_server_client_connected(peer_id):
	print("Client conection: %s" % peer_id)


func _on_web_socket_server_message_received(peer_id, message):
	print("Message")
	print(peer_id)
	print(message)
