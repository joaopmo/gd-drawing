extends CharacterBody3D


@onready var head = $head
@onready var standing_collision_shape = $StandingCollisionShape
@onready var crouching_collision_shape = $CrouchingCollisionShape
@onready var ray_cast_3d = $RayCast3D
@onready var crosshair_ray_cast = $head/CrosshairRayCast
@onready var crosshair = $head/Crosshair


@export var camera_sensitivity = 0.2

signal brush_size_change(size : float)
signal brush_color_change(color : Color)

const lerp_weight = 10.0
const crouching_height = 1.3
const standing_height = 1.8

const walking_speed = 5.0
const sprinting_speed = 8.0
const crouching_speed = 3.0

var current_speed = 5.0
var current_cam_sens = camera_sensitivity
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction = Vector3.ZERO
		

func draw_collision_events():
	if crosshair_ray_cast.is_colliding():
		var position = crosshair_ray_cast.get_collision_point()
		var normal = crosshair_ray_cast.get_collision_normal()
		var plane = Plane(normal, position)
		var dist = absf(plane.distance_to(global_position))
		crosshair.visible = true
	else:
		crosshair.visible = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	brush_size_change.emit(crosshair.brush_size)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * current_cam_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * current_cam_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			crosshair.change_size(crosshair.brush_size + 1)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			crosshair.change_size(crosshair.brush_size - 1)
		brush_size_change.emit(crosshair.brush_size)
	if event is InputEventKey:
		if event.is_action_pressed("red"):
			brush_color_change.emit(Color(1.0, 0.0, 0.0))
		if event.is_action_pressed("green"):
			brush_color_change.emit(Color(0.0, 1.0, 0.0))
		if event.is_action_pressed("blue"):
			brush_color_change.emit(Color(0.0, 0.0, 1.0))
			

func _physics_process(delta):
	draw_collision_events()
	
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y, crouching_height, delta * lerp_weight)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
	elif not ray_cast_3d.is_colliding():
		head.position.y = lerp(head.position.y, standing_height, delta * lerp_weight)
		current_speed = sprinting_speed if Input.is_action_pressed("sprint") else walking_speed
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
				
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var current_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = lerp(direction, current_dir, delta * lerp_weight)
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()


func _on_brush_drawing_start():
	current_cam_sens = camera_sensitivity * 0.6


func _on_brush_drawing_stop():
	camera_sensitivity = camera_sensitivity
