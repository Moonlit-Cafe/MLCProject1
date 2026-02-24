## Handles the loading, saving, and referencing of all items, enemies, behaviors, etc.
extends Node

#region Declarations
enum ItemType {
	MATERIAL,
	USABLE,
	EQUIPPABLE,
	WEAPON
}
enum DataType {
	ITEM,
	ACTION_SHAPE,
	ACTION,
	BEHAVIOR,
	ENEMY
}

@export_category("Item Data")
@export_file(".csv") var material_data : String = "" ## Full collection of material items
@export_file(".csv") var usable_data : String = ""
@export_file(".csv") var equippable_data : String = ""
@export_file(".csv") var weapon_data : String = ""
@export_category("Skill Data")
@export_category("Enemy Data")
@export_category("Generation Data")

var item_compendium : Dictionary[StringName, Item]
var resource_count : Dictionary[StringName, int] = {
	&"Material": 0,
	&"Usable": 0,
	&"Equippable": 0,
	&"Weapon": 0,
	&"ActionShape": 0,
	&"Action": 0,
	&"Behavior": 0,
	&"Enemy": 0,
}
#endregion

#region Events
func _ready() -> void:
	print("Initializing: ResourceManager")
	_load_item_compendium()
	
	print(item_compendium)

## Loads all the items available within the game
func _load_item_compendium() -> void:
	print("Loading: Items")
	_load_i_type_compendium(ItemType.MATERIAL)

## Loads all the items specific to [member material_data]
func _load_i_type_compendium(type: ItemType):
	var comp_access : String = ""
	var id_type : StringName = &""
	match(type):
		ItemType.MATERIAL:
			if not material_data:
				push_warning("@ResourceManager: There is no connected material data file, skipping...")
				return {}
			id_type = &"MAT_%s"
			comp_access = material_data
		_:
			push_warning("@ResourceManager: The given ItemType is incorrect, returning empty dictionary.")
			return {}
	
	var i : int = 0
	var data = CSVAccess.load_csv_data(comp_access)
	for item_name in data.keys():
		var item := MaterialItem.new()
		item.i_name = item_name
		item.id = id_type % i
		item.load_data(data.get(item_name))
		add_item(item)
		i += 1

func add_item(item: Item) -> void:
	item_compendium.set(item.id, item)
	if item is MaterialItem:
		resource_count.set(&"Material", resource_count.get(&"Material") + 1)

func remove_item(id: String) -> void:
	var item : Item = item_compendium.get(id)
	if item is MaterialItem:
		resource_count.set(&"Material", resource_count.get(&"Material") - 1)
	item_compendium.erase(id)
	

func save_data() -> void:
	_save_item_compendium()

func _save_item_compendium() -> void:
	var material_dict : Dictionary[String, Dictionary] = {}
	var usable_dict : Dictionary[String, Dictionary] = {}
	var equippable_dict : Dictionary[String, Dictionary] = {}
	var weapon_dict : Dictionary[String, Dictionary] = {}
	for item in item_compendium.keys():
		var item_data = item_compendium.get(item).save_data()
		if "MAT" in item:
			material_dict.set(item_compendium.get(item).i_name, item_data)
		elif "USE" in item:
			usable_dict.set(item_compendium.get(item).i_name, item_data)
		elif "EQP" in item:
			equippable_dict.set(item_compendium.get(item).i_name, item_data)
		elif "WEP" in item:
			weapon_dict.set(item_compendium.get(item).i_name, item_data)
		else:
			push_error("@ResourceManager: Item's id type not found.")
	
	if material_data != "":
		CSVAccess.save_csv_data(material_data, material_dict)
	
	if usable_data != "":
		CSVAccess.save_csv_data(usable_data, usable_dict)
	
	if equippable_data != "":
		CSVAccess.save_csv_data(equippable_data, equippable_dict)
	
	if weapon_data != "":
		CSVAccess.save_csv_data(weapon_data, weapon_dict)

func get_data_count(data_type: DataType, item_type: int = -1) -> int:
	match(data_type):
		DataType.ITEM:
			if item_type == -1:
				var p1 : int = resource_count.get(&"Material") + resource_count.get(&"Usable")
				var p2 : int = resource_count.get(&"Equippable") + resource_count.get(&"Weapon")
				return p1 + p2
			
			match(item_type):
				ItemType.MATERIAL:
					return resource_count.get(&"Material")
				ItemType.USABLE:
					return resource_count.get(&"Usable")
				ItemType.EQUIPPABLE:
					return resource_count.get(&"Equippable")
				ItemType.WEAPON:
					return resource_count.get(&"Weapon")
				_:
					push_warning("@ResourceManager: Invalid ItemType")
					return 0
		DataType.ACTION_SHAPE:
			return resource_count.get(&"ActionShape")
		DataType.ACTION:
			return resource_count.get(&"Action")
		DataType.BEHAVIOR:
			return resource_count.get(&"Behavior")
		DataType.ENEMY:
			return resource_count.get(&"Enemy")
		_:
			push_warning("@ResourceManager: Invalid DataType")
			return 0
#endregion
