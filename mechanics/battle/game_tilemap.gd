## The tilemap system we use for Crafting Crawler.
class_name GameTileMap extends Node3D

#region Declarations
@export var columns : Array[Array] = []
@export var tile_references : Dictionary[StringName, BasicTile] = {} ## References to 'origin' tile for duplications.
#endregion

#region Events
static func generate_map(zone_data: ZoneData) -> GameTileMap:
	var rng := RandomNumberGenerator.new()
	var map := GameTileMap.new()
	for y in range(zone_data.map_size.y):
		var col_array : Array[TileColumn] = []
		for x in range(zone_data.map_size.x):
			var new_column = TileColumn.generate_column(map, zone_data, rng)
			col_array.append(new_column)
			map.add_child(new_column)
			new_column.position = Vector3(x, 0, y)
		map.columns.append(col_array)
	return map
#endregion
