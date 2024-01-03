// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_paint : source_color, filter_linear, repeat_enable;
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;
uniform float specular;
uniform float metallic;
varying vec3 uv1_triplanar_pos;
uniform float uv1_blend_sharpness = 1.0;
varying vec3 uv1_power_normal;
uniform vec3 uv1_scale = vec3(1.0);
uniform vec3 uv1_offset;
uniform bool triplanar = false;



void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
	
	if(triplanar){
		vec3 normal = NORMAL;
		TANGENT = vec3(0.0,0.0,-1.0) * abs(normal.x);
		TANGENT+= vec3(1.0,0.0,0.0) * abs(normal.y);
		TANGENT+= vec3(1.0,0.0,0.0) * abs(normal.z);
		TANGENT = normalize(TANGENT);
		BINORMAL = vec3(0.0,1.0,0.0) * abs(normal.x);
		BINORMAL+= vec3(0.0,0.0,-1.0) * abs(normal.y);
		BINORMAL+= vec3(0.0,1.0,0.0) * abs(normal.z);
		BINORMAL = normalize(BINORMAL);
		uv1_power_normal=pow(abs(NORMAL),vec3(uv1_blend_sharpness));
		uv1_triplanar_pos = VERTEX * uv1_scale + uv1_offset;
		uv1_power_normal/=dot(uv1_power_normal,vec3(1.0));
		uv1_triplanar_pos *= vec3(1.0,-1.0, 1.0);
	} else {
		uv1_triplanar_pos = vec3(UV, 0.0); 
	}
}




vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	
	if(triplanar) {
		samp+= texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
		samp+= texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
		samp+= texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	} else {
		samp = texture(p_sampler, p_triplanar_pos.xy);
	}
	
	return samp;
}


void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = triplanar_texture(texture_albedo, uv1_power_normal, uv1_triplanar_pos);
	vec4 paint_tex = texture(texture_paint, base_uv);
	ALBEDO = albedo.rgb * mix(vec3(albedo_tex.xyz), vec3(paint_tex.xyz), paint_tex.a).rgb;
	float metallic_tex = dot(triplanar_texture(texture_metallic, uv1_power_normal, uv1_triplanar_pos), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(triplanar_texture(texture_roughness, uv1_power_normal, uv1_triplanar_pos), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
}