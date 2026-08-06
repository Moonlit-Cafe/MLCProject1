## Carries the meshes for a Tile and places them into a column for verticality in maps.
class_name TileColumn extends Node3D

#region Declarations
@export var tiles : Array[BasicTile] = [] ## All tiles within the column.
@export var top_most_tile : BasicTile ## The topmost tile within the column for easy access.
#endregion

#region Statics
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

static func rebuild_column(data: Dictionary[StringName, Variant], new_name: StringName) -> TileColumn:
	var new_column := TileColumn.new()
	new_column.name = new_name
	for tile_name in data.get(&"tiles").keys():
		var new_tile := BasicTile.rebuild_tile(data.get(&"tiles").get(tile_name), tile_name)
		new_column.tiles.append(new_tile)
	
	for tile in new_column.tiles:
		if tile.name != data.get(&"top_tile"):
			continue
		new_column.top_most_tile = tile
	return new_column
#endregion

#region Events
func save_data() -> Dictionary[StringName, Variant]:
	var dict : Dictionary[StringName, Variant] = {
		&"tiles" : {},
		&"position": position,
		&"top_tile": top_most_tile.name
	}
	
	var tile_data : Dictionary[StringName, Variant] = {}
	for tile in tiles:
		var tile_dict := tile.save_data()
		tile_data.set(tile.name, tile_dict)
	dict.set(&"tiles", tile_data)
	return dict
#endregion
