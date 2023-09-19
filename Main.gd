extends Node2D

@onready var server : WebSocketServer = $WebSocketServer
@export var line_width = 3.0

var PORT = 8080
var thread: Thread

var characters: Array[PackedVector2Array] = [PackedVector2Array()]
var py_peer_id := 0

func _ready():
	var err = server.listen(PORT)
	if err == OK:
		thread  = Thread.new()
		thread.start(call_py_on_thread.bind(PORT))
	else:
		print("Error listening on port %s" % PORT)



func _process(_delta):
	if Input.is_action_just_pressed("ui_ctrl"):
		characters = [PackedVector2Array()]
	
	if Input.is_action_just_pressed("ui_left_click") and not characters.back().is_empty():
		characters.push_back(PackedVector2Array())
		
	if Input.is_action_pressed("ui_ctrl") and Input.is_action_pressed("ui_left_click"):
		insert_point()	

	if Input.is_action_just_released("ui_ctrl"):
		server.send(py_peer_id, JSON.stringify({"type": "char", "data": characters}))
	
		
	queue_redraw()
	
		
		
func _draw():
	for line in characters:
		if line.size() >= 2:
			draw_polyline(line, Color(1.0, 0.0, 0.0), line_width, true)
			
			
func call_py_on_thread(port):
	var output = []
	var status = OS.execute("sh", ["python/linux.sh", port], output, true)
	if status != 0:
		print("Error runing python script")
	print("Python output ", output)

		
		
func insert_point():
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	
	if characters.back().is_empty() or not characters.back()[-1].is_equal_approx(mouse_pos):
		characters.back().push_back(mouse_pos)


func _exit_tree():
	thread.wait_to_finish()


func _on_web_socket_server_client_connected(peer_id):
	print("Connected to %s" % peer_id)
	py_peer_id = peer_id
