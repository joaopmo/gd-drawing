extends MeshInstance3D

@onready var crosshair_viewport: SubViewport = $"../CrosshairViewport"

func _ready():
	(mesh.material as ShaderMaterial).set_shader_parameter("texture_paint", get_node('/root/Main/Crosshair/CrosshairViewport').get_texture())
	

func _on_player_crosshair_ray_cast_start(crosshair_ray_cast: RayCast3D):
	visible = true
	var point = crosshair_ray_cast.get_collision_point()
	var normal = crosshair_ray_cast.get_collision_normal()
	global_transform.origin = point + normal / 10000.0
	match normal:
		Vector3.LEFT:
			(mesh as QuadMesh).orientation = PlaneMesh.FACE_X
			(mesh as QuadMesh).flip_faces = true
		Vector3.UP:
			(mesh as QuadMesh).orientation = PlaneMesh.FACE_Y
			(mesh as QuadMesh).flip_faces = false
		Vector3.FORWARD:
			(mesh as QuadMesh).orientation = PlaneMesh.FACE_Z
			(mesh as QuadMesh).flip_faces = true
	

func _on_player_crosshair_ray_cast_stop(_crosshair_ray_cast):
	visible = false
