extends CharacterBody3D

@onready var head = $Head
@onready var standing_collision_shape = $StandingCollisionShape
@onready var crouching_collision_shape = $CrouchingCollisionShape
@onready var crouching_ray_cast = $CrouchingRayCast
@onready var crosshair_ray_cast = $Head/CrosshairRayCast

@export var camera_sensitivity := 0.2
@export var brush_size := 10.0
@export var brush_color := Color(1.0, 0.0, 0.0)

signal brush_size_change(size: float)
signal brush_color_change(color: Color)
signal drawing_start(crosshair_ray_cast: RayCast3D)
signal drawing_stop(crosshair_ray_cast: RayCast3D)
signal drawing_input(crosshair_ray_cast: RayCast3D)
signal crosshair_ray_cast_start(crosshair_ray_cast: RayCast3D)
signal crosshair_ray_cast_stop(crosshair_ray_cast: RayCast3D)

const lerp_weight = 10.0
const crouching_height = 1.3
const standing_height = 1.8
const min_brush_size = 5.0
const max_brush_size = 100.0

const walking_speed = 5.0
const sprinting_speed = 8.0
const crouching_speed = 3.0
const jump_velocity = 4.5

var current_speed = 5.0
var current_cam_sens = camera_sensitivity
var is_drawing = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction = Vector3.ZERO
	
	
func crosshair_ray_cast_events():
	if crosshair_ray_cast.is_colliding():
		crosshair_ray_cast_start.emit(crosshair_ray_cast)
	else:
		crosshair_ray_cast_stop.emit(crosshair_ray_cast)
		if is_drawing:
			drawing_stop.emit(crosshair_ray_cast)
			is_drawing = false
		return
		
	if Input.is_action_just_pressed("ui_left_click"):
		is_drawing = true
		drawing_start.emit(crosshair_ray_cast)
		current_cam_sens = camera_sensitivity * 0.6
	elif Input.is_action_just_released("ui_left_click"):
		is_drawing = false
		drawing_stop.emit(crosshair_ray_cast)
		current_cam_sens = camera_sensitivity
	elif Input.is_action_pressed("ui_left_click"):
		drawing_input.emit(crosshair_ray_cast)
		

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	brush_size_change.emit(brush_size)
	brush_color_change.emit(brush_color)
	

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * current_cam_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * current_cam_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			brush_size += brush_size * 0.1 
			brush_size = minf(brush_size, max_brush_size)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			brush_size -= brush_size * 0.1 
			brush_size = maxf(brush_size, min_brush_size)
		brush_size_change.emit(brush_size)
		
	elif event is InputEventKey:
		if event.is_action_pressed("red"):
			brush_color = Color.RED
		elif event.is_action_pressed("green"):
			brush_color = Color.GREEN
		elif event.is_action_pressed("blue"):
			brush_color = Color.BLUE
		brush_color_change.emit(brush_color)
			
func _process(_delta):
	crosshair_ray_cast_events()


func _physics_process(delta):
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y, crouching_height, delta * lerp_weight)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
	elif not crouching_ray_cast.is_colliding():
		head.position.y = lerp(head.position.y, standing_height, delta * lerp_weight)
		current_speed = sprinting_speed if Input.is_action_pressed("sprint") else walking_speed
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
				
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

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

