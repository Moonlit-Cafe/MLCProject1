## Handles loading textures that aren't strictly set dynamically
class_name TextureLoader extends Node

#region Declarations
@export var item_textures : Dictionary[StringName, TextureHolder] = {}
#endregion

#region Events
func grab_item_texture(tex_name: StringName, pos: Vector2i) -> AtlasTexture:
	if not item_textures.has(tex_name):
		return null
	
	var tex_holder : TextureHolder = item_textures.get(tex_name)
	if Vector2i(tex_holder.atlas.get_size()) == tex_holder.unit_size:
		return tex_holder.atlas
	
	if (pos.x < 0) or (pos.y < 0):
		return null
	
	if ((pos.x + 1) * tex_holder.unit_size.x > tex_holder.atlas.get_width()):
		return null
	elif ((pos.y + 1) * tex_holder.unit_size.y > tex_holder.atlas.get_height()):
		return null
	
	var ret_tex : AtlasTexture = AtlasTexture.new()
	ret_tex.atlas = tex_holder.atlas
	var rect_size = tex_holder.unit_size
	var rect_pos = Vector2(pos.x * tex_holder.unit_size.y, pos.y * tex_holder.unit_size.y)
	var ret_region : Rect2 = Rect2(rect_pos, rect_size)
	ret_tex.region = ret_region
	return ret_tex
#endregion
