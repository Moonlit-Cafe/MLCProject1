## The very basic tile used for the game.
class_name BasicTile extends Node3D

#region Declarations
## The type of shader for how to wrap the given texture around the tile.
enum TextureType {
	SOLID, ## Each face of the tile uses the same texture.
	COLUMN, ## The top and bottom faces use a separate part of the texture from the sides.
	TEXTURE ## All sides of the tile use a unique part of the same texture.
}

## The collection of shaders access by the BasicTile for texture wrapping.
const SHADERS : Dictionary[TextureType, String] = {
	TextureType.SOLID: "res://assets/shaders/tiles/solid_tile.gdshader",
	TextureType.COLUMN: "res://assets/shaders/tiles/column_tile.gdshader",
	TextureType.TEXTURE: "res://assets/shaders/tiles/tex_tile.gdshader"
}

@export var tile_texture : Texture2D ## The texture used by the tile.
@export var texture_type : TextureType = TextureType.SOLID ## The type of shader to use for texture wrapping.
#endregion

#region Events
## Creates a tile with the given parameters and returns it.
# TODO: Eventually, replace this with a data type specifically for generating these.
static func create_tile(texture: Texture2D, tex_type: TextureType) -> BasicTile:
	var new_tile := BasicTile.new()
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1, 1, 1)
	mesh_instance.mesh = mesh
	new_tile.add_child(mesh_instance)
	new_tile.update_texture(texture, tex_type)
	return new_tile

## Used for when the texture is changed either during creation or during runtime.
func update_texture(new_texture: Texture2D=null, new_type: TextureType=TextureType.SOLID) -> void:
	var mesh := $MeshInstance3D
	if not new_texture:
		tile_texture = new_texture
	
	var shader_material : ShaderMaterial
	if new_type != texture_type:
		shader_material = _get_shader(new_type)
	else:
		shader_material = mesh.mesh.surface_get_material(0)
	
	if not shader_material:
		shader_material = _get_shader(new_type)
	
	shader_material.set_shader_parameter(&"tex", new_texture)
	mesh.mesh.material = shader_material
	return

## Grabs the specific shader needed for a specific [enum TextureType].
func _get_shader(shader_type: TextureType) -> ShaderMaterial:
	var s_mat := ShaderMaterial.new()
	s_mat.shader = ResourceLoader.load(SHADERS.get(shader_type))
	return s_mat
#endregion
