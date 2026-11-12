## The tilemap system we use for Crafting Crawler.
class_name GameTileMap extends Node3D

#region Declarations
@export var columns : Array[TileColumn] = [] ## The full list of columns on the map.
@export var battle_tiles : Array[BattleTile] = [] ## All of the battle_tiles.
@export var tile_references : Dictionary[StringName, BasicTile] = {} ## References to 'origin' tile for duplications.
@export var topmost_tiles : Array[BasicTile] = [] ## All the topmost tiles to be used for BattleTile generation

var _tile_position_cache : Dictionary[BasicTile, Vector3] = {}
var _tile_at_position_cache : Dictionary[Vector3i, BasicTile] = {}
#endregion

#region Statics
static func generate_map(zone_data: ZoneData, map_name: StringName=&"NewMap", rng_seed: int = -1) -> GameTileMap:
	var rng := RandomNumberGenerator.new()
	if rng_seed >= 0:
		rng.seed = rng_seed
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
	map._rebuild_lookup_caches()
	return map

static func _position_key(pos: Vector3) -> Vector3i:
	return Vector3i(roundi(pos.x), roundi(pos.y), roundi(pos.z))

static func rebuild_map(data: Dictionary[StringName, Variant], new_name : StringName) -> GameTileMap:
	var map := GameTileMap.new()
	var column_holder := Node3D.new()
	var b_tile_holder = Node3D.new()
	column_holder.name = "Columns"
	b_tile_holder.name = "BattleTiles"
	map.add_child(column_holder)
	map.add_child(b_tile_holder)
	map.name = new_name
	var saved_columns : Dictionary = data.get(&"columns", {})
	for column_name in saved_columns:
		var column_data : Dictionary[StringName, Variant] = saved_columns.get(column_name)
		var new_column := TileColumn.rebuild_column(column_data, column_name)
		column_holder.add_child(new_column)
		new_column.position = column_data.get(&"position", Vector3.ZERO)
		map.topmost_tiles.append(new_column.top_most_tile)
		map.columns.append(new_column)
	
	var saved_battle_tiles : Dictionary = data.get(&"battle_tiles", {})
	for b_tile in saved_battle_tiles.keys():
		var b_tile_data : Dictionary[StringName, Variant] = saved_battle_tiles.get(b_tile)
		var new_battle_tile := BattleTile.rebuild_battle_tile(b_tile_data, b_tile)
		b_tile_holder.add_child(new_battle_tile)
		new_battle_tile.position = b_tile_data.get(&"position", Vector3.ZERO)
		map.battle_tiles.append(new_battle_tile)
	map._rebuild_lookup_caches()
	return map
#endregion

#region Events
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
	if battle_tiles.is_empty():
		Global.logs.post_warning(self, "No battle tiles exist to choose from.")
		return null
	return battle_tiles.pick_random()

func _rebuild_lookup_caches() -> void:
	_tile_position_cache.clear()
	_tile_at_position_cache.clear()
	for column in columns:
		for tile in column.tiles:
			var world_pos := Vector3(column.position.x, tile.position.y, column.position.z)
			_tile_position_cache[tile] = world_pos
			_tile_at_position_cache[_position_key(world_pos)] = tile

func get_tile_at_position(pos: Vector3) -> BasicTile:
	if _tile_at_position_cache.is_empty() and not columns.is_empty():
		_rebuild_lookup_caches()
	return _tile_at_position_cache.get(_position_key(pos))

## Using an already known [param tile], attempts to grab it's full local position.
func get_tile_position(tile: BasicTile) -> Vector3:
	if _tile_position_cache.is_empty() and not columns.is_empty():
		_rebuild_lookup_caches()
	if _tile_position_cache.has(tile):
		return _tile_position_cache.get(tile)
	
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
