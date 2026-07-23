## Carries the meshes for a Tile and places them into a column for verticality in maps.
class_name TileColumn extends Node3D

#region Declarations
@export var tiles : Array[BasicTile] = [] ## All tiles within the column.
@export var top_most_tile : BasicTile ## The topmost tile within the column for easy access.
#endregion

#region Events
static func generate_column(map: GameTileMap, zone_data: ZoneData,
	rng: RandomNumberGenerator, column_name: StringName="NewColumn") -> TileColumn:
	var new_column := TileColumn.new()
	new_column.name = column_name
	
	var height : int = roundi(zone_data.height_range.sample(rng.randf()))
	for z in range(height):
		var pick_tile = rng.randi_range(0, zone_data.tiles_used.size() - 1)
		var tile_id = zone_data.tiles_used.get(pick_tile)
		var new_tile : BasicTile
		if map.tile_references.has(tile_id):
			var tile_ref : BasicTile = map.tile_references.get(tile_id)
			new_tile = tile_ref.duplicate()
		else:
			var tile_data : GameTileData = GlobalResources.get_data(GlobalResources.DataType.TILE, tile_id)
			new_tile = BasicTile.generate_tile(tile_data.texture, tile_data.texture_type, "Tile_%s" % z)
			map.tile_references.set(tile_id, new_tile)
		
		new_column.tiles.append(new_tile)
		new_column.add_child(new_tile)
		new_tile.position = Vector3(0, z, 0)
		
		if z == (height - 1):
			new_column.top_most_tile = new_tile
	return new_column
#endregion
