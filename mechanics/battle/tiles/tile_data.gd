## A small resource to hold data for Tiles while inside GlobalResources.
class_name GameTileData extends Resource

#region Declarations
@export var texture : Texture2D
@export var texture_type : BasicTile.TextureType
#endregion

#region Events
static func create_tile_data(tex_path: String, tex_type: int) -> GameTileData:
	var new_tile_data := GameTileData.new()
	var tex : Texture2D = ResourceLoader.load(tex_path, "Texture2D")
	new_tile_data.texture = tex
	new_tile_data.texture_type = tex_type as BasicTile.TextureType
	return new_tile_data
#endregion
