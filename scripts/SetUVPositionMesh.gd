extends MeshInstance3D

enum Surface {ZERO}

func _ready():
	LevelUVPosition.set_mesh(self)
	(get_surface_override_material(0) as ShaderMaterial).set_shader_parameter("texture_albedo", (mesh.surface_get_material(0) as StandardMaterial3D).get_texture(BaseMaterial3D.TEXTURE_ALBEDO))
	(get_surface_override_material(0) as ShaderMaterial).set_shader_parameter("texture_paint", get_node('/root/Main/DrawViewport').get_texture())

