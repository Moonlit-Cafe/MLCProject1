## Handles the loading, saving, and referencing of all items, enemies, behaviors, etc.
extends Node

#region Declarations
## Enum used to classify the type of data a resource is described as.
enum DataType {
	CHARACTER,
	TILE, ## Used for declaring/getting GameTileData for BasicTile generation.
	ACTION,
	ACTION_SHAPE,
	ITEM,
	RECIPE
}
enum CustomDataType {
	VECTOR
}

@export_file(".json") var action_data_reference : String ## Where all the actions are housed
@export_file(".json") var action_shape_data_reference : String ## Where all the action shape data is located
@export_file(".json") var items_reference : String ## Contains all the items within the game
@export_file(".json") var recipe_reference : String ## Contains the data for all the game's recipes
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
	_load_recipes()
	_load_entities()
	_load_tiles()

## Method used to set data in [member _resources]
func set_data(d_type: DataType, id: String, value: Variant) -> void:
	if not (_resources.has(d_type)):
		_resources.set(d_type, {})
	
	_resources.get(d_type).set(id, value)

## [method get_data] applied specifically to items.
func get_item(id: String) -> BasicItem:
	return get_data(DataType.ITEM, id)

## Method used to check if an item exists within [member _resources]
func check_data(d_type: DataType, id: String) -> bool:
	if not get_data(d_type, id):
		return false
	
	return true

## Method used to retrieve data from [member _resources]
func get_data(d_type: DataType, id: String) -> Variant:
	var resource_dir : Dictionary = _resources.get(d_type, {})
	if resource_dir == {}:
		return null
	
	return resource_dir.get(id, null)

## Grabs the size of a specific data Dictionary:
func get_data_count(d_type: DataType) -> int:
	if not _resources.has(d_type):
		return -1
	
	return _resources.get(d_type).size()

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
		var new_item := BasicItem.new()
		new_item.set_data(data.get(item_id), item_id)
		set_data(DataType.ITEM, item_id, new_item)
	Global.logs.post_message(self, "loaded items successfully")

## Loads up all the recipes within the game.
func _load_recipes() -> void:
	if not recipe_reference:
		Global.logs.post_warning(self, "no file used for recipe_reference")
		return
	
	Global.logs.post_message(self, "loading recipe data")
	
	var data = _load_data(recipe_reference)
	
	for recipe_id in data.keys():
		var recipe_data = data.get(recipe_id)
		if not recipe_data is Dictionary:
			Global.logs.post_warning(self, "recipe %s is not returning a dictionary on load" % recipe_id)
			return
		
		if not recipe_data.has("ingredients"):
			Global.logs.post_warning(self, "recipe %s does not have an ingredients list set, skipping" % recipe_id)
			return
		
		var ingredients = recipe_data.get("ingredients")
		if not ingredients is Dictionary:
			Global.logs.post_warning(self, "recipe %s has ingredients set, but it's not a dictionary" % recipe_id)
			print(typeof(ingredients))
			return
		
		var type_ingredients : Dictionary[StringName, int] = {}
		for item in ingredients.keys():
			if not item is String:
				Global.logs.post_warning(self, "an item within the ingredients list is not a string")
				return
			if not check_data(DataType.ITEM, item):
				Global.logs.post_warning(self, "an ingredient is missing from the recipe, skipping inclusion")
				ingredients.erase(item)
				continue
			type_ingredients.set(item, int(ingredients.get(item)))
		
		var result = recipe_data.get("result")
		if not result is String:
			Global.logs.post_warning(self, "expected a String for result in %s, skipping" % recipe_id)
			return
		
		var count = recipe_data.get("count")
		if not count is float and not count is int:
			Global.logs.post_warning(self, "expected a number for count in %s, skipping" % recipe_id)
			return
		
		var new_recipe := Recipe.generate_recipe(type_ingredients, result, int(count))
		set_data(DataType.RECIPE, recipe_id, new_recipe)
		for item_id in ingredients.keys():
			var item : BasicItem = get_data(DataType.ITEM, item_id)
			item.recipes.append(recipe_id)
	Global.logs.post_message(self, "loaded recipes successfully")

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

func id_preface(idx: int) -> String:
	if idx < 10:
		return "00%s" % idx
	elif idx < 100:
		return "0%s" % idx
	else:
		return str(idx)
#endregion
