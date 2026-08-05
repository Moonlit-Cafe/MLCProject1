## The tilemap system we use for Crafting Crawler.
class_name GameTileMap extends Node3D

#region Declarations
@export var columns : Array[TileColumn] = [] ## The full list of columns on the map.
@export var battle_tiles : Array[BattleTile] = [] ## All of the battle_tiles.
@export var tile_references : Dictionary[StringName, BasicTile] = {} ## References to 'origin' tile for duplications.
@export var topmost_tiles : Array[BasicTile] = [] ## All the topmost tiles to be used for BattleTile generation
#endregion

#region Events
static func generate_map(zone_data: ZoneData, map_name: StringName=&"NewMap") -> GameTileMap:
	var rng := RandomNumberGenerator.new()
	var map := GameTileMap.new()
	var column_holder := Node3D.new()
	column_holder.name = "Columns"
	map.add_child(column_holder)
	map.name = map_name
	for y in range(zone_data.map_size.y):
		for x in range(zone_data.map_size.x):
			var new_column = TileColumn.generate_column(map, zone_data, rng, "Column(%s, %s)" % [x, y])
			column_holder.add_child(new_column)
			new_column.position = Vector3(x, 0, y)
			map.topmost_tiles.append(new_column.top_most_tile)
			map.columns.append(new_column)
	return map

static func rebuild_map(data: Dictionary[StringName, Variant], new_name : StringName) -> GameTileMap:
	var map := GameTileMap.new()
	var column_holder := Node3D.new()
	var b_tile_holder = Node3D.new()
	column_holder.name = "Columns"
	b_tile_holder.name = "BattleTiles"
	map.add_child(column_holder)
	map.add_child(b_tile_holder)
	map.name = new_name
	for column_name in data.get(&"columns"):
		var new_column := TileColumn.rebuild_column(data.get(&"columns").get(column_name), column_name)
		column_holder.add_child(new_column)
		new_column.position = data.get(&"columns").get(column_name).get(&"position")
		map.topmost_tiles.append(new_column.top_most_tile)
		map.columns.append(new_column)
	
	for b_tile in data.get(&"battle_tiles").keys():
		var new_battle_tile := BattleTile.rebuild_battle_tile(data.get(&"battle_tiles").get(b_tile),
		b_tile)
		b_tile_holder.add_child(new_battle_tile)
		new_battle_tile.position = data.get(&"battle_tiles").get(b_tile).get(&"position")
		map.battle_tiles.append(new_battle_tile)
	return map

func generate_battle_tiles() -> void:
	if not topmost_tiles:
		Global.logs.post_warning(self, "There's no tiles to reference for BattleTile generation.")
		return
	
	var b_tile_holder := Node3D.new()
	b_tile_holder.name = "BattleTiles"
	add_child(b_tile_holder)
	
	for tile in topmost_tiles:
		var new_b_tile_pos = get_tile_position(tile) + Vector3(0, 1, 0)
		var new_battle_tile := BattleTile.generate_battle_tile("BattleTile(%s, %s)" % [new_b_tile_pos.x,
			new_b_tile_pos.z])
		b_tile_holder.add_child(new_battle_tile)
		new_battle_tile.position = new_b_tile_pos
		battle_tiles.append(new_battle_tile)

func get_random_tile() -> BattleTile:
	return battle_tiles.pick_random()

# TODO: Optimize this
## Using a [param pos], attempts to get the [class BasicTile] at that point.
func get_tile_at_position(pos: Vector3) -> BasicTile:
	for column in columns:
		if not column.position.distance_to(Vector3(pos.x, 0, pos.z)) <= 0.001:
			continue
		
		for tile in column.tiles:
			if not tile.position.distance_to(Vector3(0, pos.y, 0)) <= 0.001:
				continue
			
			return tile
	
	return null

# TODO: Optimize this
## Using an already known [param tile], attempts to grab it's full local position.
func get_tile_position(tile: BasicTile) -> Vector3:
	for column in columns:
		for c_tile in column.tiles:
			if c_tile == tile:
				return Vector3(column.position.x, c_tile.position.y, column.position.z)
	
	return Vector3(-1, -1, -1)

func save_data() -> Dictionary[StringName, Variant]:
	var dict : Dictionary[StringName, Variant] = {
		&"columns" : {},
		&"battle_tiles": {}
	}
	
	var column_data : Dictionary[StringName, Variant] = {}
	for column in columns:
		var column_dict : Dictionary[StringName, Variant] = column.save_data()
		column_data.set(column.name, column_dict)
	dict.set(&"columns", column_data)
	
	var b_tile_data : Dictionary[StringName, Variant] = {}
	for b_tile in battle_tiles:
		var b_tile_dict : Dictionary[StringName, Variant] = b_tile.save_data()
		b_tile_data.set(b_tile.name, b_tile_dict)
	dict.set(&"battle_tiles", b_tile_data)
	
	return dict
#endregion
