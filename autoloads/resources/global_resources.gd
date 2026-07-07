## Handles the loading, saving, and referencing of all items, enemies, behaviors, etc.
extends Node

#region Declarations
## Enum used to classify the type of data a resource is described as.
enum DataType {
	ENTITY, ## Used for declaring/getting TileEntity paths for packed_scenes.
	TILE ## Used for declaring/getting GameTileData for BasicTile generation.
}

@export_file(".json") var entity_scene_reference : String ## Contains the path references for all entities
@export_file(".json") var tile_data_reference : String ## Contains all the tile data within the game.

var _resources : Dictionary[DataType, Dictionary] = {} ## The full dictionary of resources in the game
#endregion

#region Events
func _ready() -> void:
	Global.logs.post_message(self, "starting to load resources")
	load_data()

## Loads up ALL data to be used for the game.
func load_data() -> void:
	_load_entities()
	_load_tiles()

## Method used to set data in [member _resources]
func set_data(d_type: DataType, id: String, value: Variant) -> void:
	if not (_resources.has(d_type)):
		_resources.set(d_type, {})
	
	_resources.get(d_type).set(id, value)

## Method used to retrieve data from [member _resources]
func get_data(d_type: DataType, id: String) -> Variant:
	var resource_dir : Dictionary = _resources.get(d_type, {})
	if resource_dir == {}:
		return null
	
	return resource_dir.get(id, null)

## Loads up all the entities within the game.
func _load_entities() -> void:
	if not entity_scene_reference:
		Global.logs.post_warning(self, "no file used for entity_scene_reference")
		return
	
	Global.logs.post_message(self, "loading entity references")
	var json := JSON.new()
	var entity_file := FileAccess.open(entity_scene_reference, FileAccess.READ)
	var error := json.parse(entity_file.get_as_text())
	if error != OK:
		Global.logs.post_error(self, json.get_error_message())
		return
	
	for entity_id in json.data.keys():
		set_data(DataType.ENTITY, entity_id, json.data.get(entity_id))
	
	entity_file.close()
	Global.logs.post_message(self, "loaded entity references successfully")

## Loads up all the tiles within the game.
func _load_tiles() -> void:
	if not tile_data_reference:
		Global.logs.post_warning(self, "no file used for tile_data_reference")
		return
	
	Global.logs.post_message(self, "loading tile data")
	var json := JSON.new()
	var tile_file := FileAccess.open(tile_data_reference, FileAccess.READ)
	var error := json.parse(tile_file.get_as_text())
	if error != OK:
		Global.logs.post_error(self, json.get_error_message())
		return
	# considerations system tutorial video games
	for tile_id in json.data.keys():
		var data : Dictionary = json.data.get(tile_id)
		var new_tile_data := GameTileData.create_tile_data(data.get("texture"), data.get("texture_type"))
		set_data(DataType.TILE, tile_id, new_tile_data)
	
	tile_file.close()
	Global.logs.post_message(self, "loaded tile data successfully")
#endregion
