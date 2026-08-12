## Handles the loading, saving, and referencing of all items, enemies, behaviors, etc.
extends Node

#region Declarations
## Enum used to classify the type of data a resource is described as.
enum DataType {
	CHARACTER,
	TILE, ## Used for declaring/getting GameTileData for BasicTile generation.
	ACTION,
	ACTION_SHAPE,
	ITEM
}
enum CustomDataType {
	VECTOR
}

@export_file(".json") var action_data_reference : String
@export_file(".json") var action_shape_data_reference : String
@export_file(".json") var items_reference : String
@export_file(".json") var characters_reference : String ## Contains the path references for all entities
@export_file(".json") var tile_data_reference : String ## Contains all the tile data within the game.

@onready var tex_loader : TextureLoader = $TextureLoader

var _resources : Dictionary[DataType, Dictionary] = {} ## The full dictionary of resources in the game
#endregion

#region Events
func _ready() -> void:
	Global.logs.post_message(self, "starting to load resources")
	load_data()

## Loads up ALL data to be used for the game.
func load_data() -> void:
	_load_action_shapes()
	_load_actions()
	_load_items()
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

## Method used to retrieve all the data of a specific type
func get_all_data(d_type: DataType) -> Dictionary:
	return _resources.get(d_type)

func _load_action_shapes() -> void:
	if not action_shape_data_reference:
		Global.logs.post_warning(self, "no file used for action_shape_data_reference.")
		return
	
	Global.logs.post_message(self, "loading action shape data")
	
	var data = _load_data(action_shape_data_reference)
	
	for action_shape_id in data.keys():
		var shape_data : Dictionary = data.get(action_shape_id)
		var new_shape := ActionShape.create_shape_data(shape_data, action_shape_id)
		set_data(DataType.ACTION_SHAPE, action_shape_id, new_shape)
	Global.logs.post_message(self, "loaded action shapes successfully")

func _load_actions() -> void:
	if not action_data_reference:
		Global.logs.post_warning(self, "no file used for action_data_reference")
		return
	
	Global.logs.post_message(self, "loading action data")
	
	var data = _load_data(action_data_reference)
	
	for action_id in data.keys():
		var action_data = data.get(action_id)
		var new_action
		match (action_data.get("type") as BaseAction.ActionType):
			BaseAction.ActionType.ATTACK:
				new_action = AttackAction.create_attack_action_data(action_data, action_id)
		set_data(DataType.ACTION, action_id, new_action)
	Global.logs.post_message(self, "loaded actions successfully")

## Loads up all the items within the game.
func _load_items() -> void:
	if not items_reference:
		Global.logs.post_warning(self, "no file used for items_reference")
		return
	
	Global.logs.post_message(self, "loading item data")
	
	var data = _load_data(items_reference)
	
	for item_id in data.keys():
		var new_item := ItemResource.new()
		new_item.set_data(data.get(item_id), item_id)
		set_data(DataType.ITEM, item_id, new_item)
	Global.logs.post_message(self, "loaded items successfully")

## Loads up all the entities within the game.
func _load_entities() -> void:
	if not characters_reference:
		Global.logs.post_warning(self, "no file used for characters_reference")
		return
	
	Global.logs.post_message(self, "loading character references")
	
	var data = _load_data(characters_reference)
	
	for entity_id in data.keys():
		var new_char = ResourceLoader.load(data.get(entity_id).get("resource"))
		new_char.id = entity_id
		set_data(DataType.CHARACTER, entity_id, new_char)
	Global.logs.post_message(self, "loaded character references successfully")

## Loads up all the tiles within the game.
func _load_tiles() -> void:
	if not tile_data_reference:
		Global.logs.post_warning(self, "no file used for tile_data_reference")
		return
	
	Global.logs.post_message(self, "loading tile data")
	
	var data = _load_data(tile_data_reference)
	# considerations system tutorial video games
	for tile_id in data.keys():
		var tile_data : Dictionary = data.get(tile_id)
		var new_tile_data := GameTileData.create_tile_data(tile_data.get("texture"), tile_data.get("texture_type"))
		set_data(DataType.TILE, tile_id, new_tile_data)
	
	Global.logs.post_message(self, "loaded tile data successfully")

func _load_data(data_path: String) -> Variant:
	var json := JSON.new()
	var file := FileAccess.open(data_path, FileAccess.READ)
	var error := json.parse(file.get_as_text())
	if error != OK:
		Global.logs.post_error(self, json.get_error_message())
		return null
	
	file.close()
	return json.data
#endregion

#region Character Query
func grab_enemies_with_tag(tag_arr: Array[EnemyCharacter.EnemyType],
							inclusive: bool = true)-> Array[EnemyCharacter]:
	var character_dict : Dictionary = get_all_data(DataType.CHARACTER)
	var ret_arr : Array[EnemyCharacter] = []
	var enemy_list : Array[EnemyCharacter] = []
	for chr in character_dict.values():
		if chr is EnemyCharacter:
			enemy_list.append(chr)
	
	for enemy in enemy_list:
		var enemy_tags := enemy.tags
		if inclusive:
			if tag_arr.any(func(t): return t in enemy_tags):
				ret_arr.append(enemy)
		else:
			if tag_arr.all(func(t): return t in enemy_tags):
				ret_arr.append(enemy)
	
	return ret_arr
#endregion

#region Helpers
func load_custom_data(data: Variant, type: CustomDataType) -> Variant:
	match (type):
		CustomDataType.VECTOR:
			var new_vector := Vector2(data.get("x"), data.get("y"))
			return new_vector
		_:
			Global.logs.post_warning(self, "given type does not match the available types.")
			return null
#endregion
