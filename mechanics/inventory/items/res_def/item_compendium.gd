## Holds the data for all existing items in the game.
class_name ItemCompendium extends Resource

@export_dir var material_compendium : String
@export_dir var usable_compendium : String
@export_dir var equip_compendium : String
@export_dir var weapon_compendium : String
@export_dir var powercore_compendium : String
var item_reference : Array[Item]

func init() -> void:
	load_items(material_compendium)
	load_items(usable_compendium)
	load_items(equip_compendium)
	load_items(weapon_compendium)
	load_items(powercore_compendium)
	
	print(item_reference)
	# TODO: Put a sort function here to sort the items by id, but also assign IDs in the right order.

func load_items(path: String) -> void:
	if path == "":
		return
	
	var dir = ResourceLoader.list_directory(path)
	for dir_item in dir:
		if "/" in dir_item:
			load_items(path + "/" + dir_item)
		else:
			var item = FileHelper.load_asset(path + "/" + dir_item)
			item.id = item.i_name.to_snake_case()
			item_reference.append(item)
