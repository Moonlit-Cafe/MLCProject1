## Handles the loading, saving, and referencing of all items, enemies, behaviors, etc.
extends Node

#region Declarations
## Enum used to classify the type of data a resource is described as.
enum DataType {
	CHARACTER,
	TILE, ## Used for declaring/getting GameTileData for BasicTile generation.
	ACTION,
	ACTION_SHAPE
}
enum CustomDataType {
	VECTOR
}

@export var registry_dictionary : Dictionary[StringName, Registry]

#@export_file(".json") var items_reference : String ## Contains all the items within the game
#@export_file(".json") var recipe_reference : String ## Contains the data for all the game's recipes
#@export_file(".json") var characters_reference : String ## Contains the path references for all entities
#@export_file(".json") var tile_data_reference : String ## Contains all the tile data within the game.
#
#@onready var tex_loader : TextureLoader = $TextureLoader
#endregion

#region Events
func grab_entry(registry_name: StringName, entry_name: StringName) -> Resource:
	if not registry_dictionary.has(registry_name):
		Global.logs.post_warning(self, "The registry \"%s\" does not exist." % registry_name)
		return null
	
	var registry : Registry = registry_dictionary.get(registry_name)
	if not registry.has(entry_name):
		Global.logs.post_warning(self, "The entry \"%s\" does not exist in registry \"%s\"" % [entry_name, registry_name])
		return null
	
	return registry.load_entry(entry_name)

func filter_entries(registry_name: StringName, property: StringName, value: Variant) -> Array[Resource]:
	if not registry_dictionary.has(registry_name):
		Global.logs.post_warning(self, "The registry \"%s\" does not exist." % registry_name)
		return []
	
	var registry : Registry = registry_dictionary.get(registry_name)
	var results : Array[StringName] = registry.filter(property, value)
	var ret_arr : Array[Resource] = []
	for result in results:
		var item = grab_entry(registry_name, result)
		ret_arr.append(item)
	
	return ret_arr

func tag_filter_entries(registry_name: StringName, tags: Array, exclusive: bool=false) -> Array[Resource]:
	if not registry_dictionary.has(registry_name):
		Global.logs.post_warning(self, "The registry \"%s\" does not exist." % registry_name)
		return []
	
	var registry : Registry = registry_dictionary.get(registry_name)
	var ids : Array[StringName] = []
	var results : Array[Resource] = []
	if exclusive:
		ids = registry.where({&"tags": func(t): return array_compare(t, tags, true)})
	else:
		ids = registry.where({&"tags": func(t): return array_compare(t, tags)})
	for id in ids:
		var res = grab_entry(registry_name, id)
		results.append(res)
	
	return results

func get_registry_size(registry_name: StringName) -> int:
	if not registry_dictionary.has(registry_name):
		Global.logs.post_warning(self, "The registry \"%s\" does not exist." % registry_name)
		return -1
	
	var registry : Registry = registry_dictionary.get(registry_name)
	return registry.size()
#endregion
#
##region Character Query
#func grab_enemies_with_tag(tag_arr: Array[EnemyCharacter.EnemyType],
#							inclusive: bool = true)-> Array[EnemyCharacter]:
#	var character_dict : Dictionary = get_all_data(DataType.CHARACTER)
#	var ret_arr : Array[EnemyCharacter] = []
#	var enemy_list : Array[EnemyCharacter] = []
#	for chr in character_dict.values():
#		if chr is EnemyCharacter:
#			enemy_list.append(chr)
#	
#	for enemy in enemy_list:
#		var enemy_tags := enemy.tags
#		if inclusive:
#			if tag_arr.any(func(t): return t in enemy_tags):
#				ret_arr.append(enemy)
#		else:
#			if tag_arr.all(func(t): return t in enemy_tags):
#				ret_arr.append(enemy)
#	
#	return ret_arr
##endregion
#
#region Helpers
func array_compare(array_1: Array, array_2: Array, all: bool=false) -> bool:
	var checked : int = 0
	for item in array_2:
		if not item in array_1:
			continue
		
		if not all:
			return true
		
		checked += 1
	
	if checked == array_2.size():
		return true
	
	return false
#endregion
