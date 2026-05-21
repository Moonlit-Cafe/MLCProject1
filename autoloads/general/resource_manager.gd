## Handles the loading, saving, and referencing of all items, enemies, behaviors, etc.
class_name ResourceManager extends Node

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
@export_file(".json") var material_data_path : String
@export_file(".json") var usable_data_path : String
@export_file(".json") var equippable_data_path : String
@export_file(".json") var equipset_data_path : String
@export_file(".json") var weapon_data_path : String
@export_category("Skill Data")
@export_file(".json") var action_shape_data_path : String
@export_file(".json") var action_data_path : String
@export_category("Enemy Data")
@export_category("Generation Data")

var item_compendium : Dictionary[StringName, Item]
var set_compendium : Dictionary[int, EquipSet]
var action_shape_compendium : Dictionary[StringName, ActionShape]
var action_compendium : Dictionary[StringName, CombatAction]
var resource_count : Dictionary[StringName, int] = {
	&"Material": 0,
	&"Usable": 0,
	&"Equippable": 0,
	&"Weapon": 0,
	&"ActionShape": 0,
	&"Action": 0,
	&"Behavior": 0,
	&"Enemy": 0
}
#endregion

#region Events
func _ready() -> void:
	await GameGlobal.ready
	print("Initializing: ResourceManager")
	load_data()

func load_data() -> void:
	_load_item_compendium()
	print(item_compendium)
	_load_action_shapes()
	_load_actions()
	_load_set_compendium()

func save_data() -> void:
	_save_item_compendium()
	_save_action_shapes()
	_save_actions()
#endregion

#region Item Compendium
## Loads all the items available within the game
func _load_item_compendium() -> void:
	print("Loading: Items")
	_load_i_type_compendium(ItemType.MATERIAL)
	_load_i_type_compendium(ItemType.EQUIPPABLE)
	print("Loaded: Items")

## Loads all the items specific to [member material_data]
func _load_i_type_compendium(type: ItemType):
	var database : Dictionary = {}
	var item
	
	match(type):
		ItemType.MATERIAL:
			database = FileHelper.load_database(material_data_path)
			item = MaterialItem.new()
		ItemType.EQUIPPABLE:
			database = FileHelper.load_database(equippable_data_path)
			item = EquippableItem.new()
		_:
			GameGlobal.logging.post_warning(self, "The given ItemType is incorrect, returning empty dictionary.")
	
	for item_id in database.keys():
		var new_item = item.duplicate()
		new_item.id = item_id
		new_item.load_data(database.get(item_id))
		add_item(item_id, item)

func add_item(item_id: String, item: Item) -> void:
	item_compendium.set(item_id, item)
	if item is MaterialItem:
		resource_count.set(&"Material", resource_count.get(&"Material") + 1)

func remove_item(id: String) -> void:
	var item : Item = item_compendium.get(id)
	if item is MaterialItem:
		resource_count.set(&"Material", resource_count.get(&"Material") - 1)
	item_compendium.erase(id)

func _save_item_compendium() -> void:
	var material_dict : Dictionary[String, Dictionary] = {}
	var usable_dict : Dictionary[String, Dictionary] = {}
	var equippable_dict : Dictionary[String, Dictionary] = {}
	var weapon_dict : Dictionary[String, Dictionary] = {}
	for item in item_compendium.keys():
		var item_data = item_compendium.get(item).save_data()
		if "MAT" in item:
			material_dict.set(item, item_data)
		elif "USE" in item:
			usable_dict.set(item, item_data)
		elif "EQP" in item:
			equippable_dict.set(item, item_data)
		elif "WEP" in item:
			weapon_dict.set(item, item_data)
		else:
			GameGlobal.logging.post_error(self, "Item's id type not found.")
	
	if material_data_path:
		FileHelper.save_database(material_data_path, material_dict)
	
	if usable_data_path:
		FileHelper.save_database(usable_data_path, usable_dict)
	
	if equippable_data_path:
		FileHelper.save_database(equippable_data_path, equippable_dict)
	
	if weapon_data_path:
		FileHelper.save_database(weapon_data_path, weapon_dict)
#endregion

#region Action Compendiums
func _load_action_shapes() -> void:
	var action_shape_data = FileHelper.load_database(action_shape_data_path)
	
	print("Loading: ActionShapes")
	for shape in action_shape_data.keys():
		var action_shape := ActionShape.new()
		action_shape.shape_id = shape
		action_shape.load_data(action_shape_data.get(shape))
		add_action_shape(action_shape)
	print("Loaded: ActionShapes")

func _load_actions() -> void:
	var action_data = FileHelper.load_database(action_data_path)
	
	print("Loading: Actions")
	if not action_data:
		GameGlobal.logging.post_warning(self, "There is no connected action data file, skipping...")
		return
	
	for action_dat in action_data.keys():
		var action := CombatAction.new()
		action.ac_id = action_dat
		action.load_data(action_data.get(action_dat))
		add_action(action)
	print("Loaded: Actions")

func add_action_shape(acs: ActionShape) -> void:
	action_shape_compendium.set(acs.shape_id, acs)
	resource_count.set(&"ActionShape", resource_count.get(&"ActionShape") + 1)

func add_action(act: CombatAction) -> void:
	action_compendium.set(act.ac_id, act)
	resource_count.set(&"Action", resource_count.get(&"Action") + 1)

func remove_action_shape(acs: ActionShape) -> void:
	action_shape_compendium.erase(acs.shape_id)
	resource_count.set(&"ActionShape", resource_count.get(&"ActionShape") - 1)

func remove_action(act: Action) -> void:
	action_compendium.erase(act.ac_id)
	resource_count.set(&"Action", resource_count.get(&"Action") - 1)

func _save_action_shapes() -> void:	
	var action_shape_dict : Dictionary[String, Dictionary] = {}
	for shape in action_shape_compendium.keys():
		print("Saving %s with array %s" % [shape.shape_name, shape.shape_pos_arr])
		action_shape_dict.set(shape, action_shape_compendium.get(shape).save_data())
	
	FileHelper.save_database(action_shape_data_path, action_shape_dict)

func _save_actions() -> void:
	var action_dict : Dictionary[String, Dictionary] = {}
	for action in action_compendium.keys():
		action_dict.set(action, action_dict.get(action).save_data())
	
	FileHelper.save_database(action_data_path, action_dict)
#endregion

#region Set Compendium
func _load_set_compendium() -> void:
	var equipset_data = FileHelper.load_database(equipset_data_path)
	
	var equip_set = EquipSet.new()
	for eqs_id in equipset_data.keys():
		var new_equip_set = equip_set.duplicate()
		new_equip_set.load_data(equipset_data.get(eqs_id))
		add_set(equip_set)

func add_set(equip_set: EquipSet) -> void:
	set_compendium.set(equip_set.set_id, equip_set)
	#set_count.set(&"Material", resource_count.get(&"Material") + 1)

#func remove_set(id: String) -> void:
	#var set_name : Item = item_compendium.get(id)
	#item_compendium.erase(id)
#endregion

#region Helpers
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
					GameGlobal.logging.post_warning(self, "Invalid ItemType")
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
			GameGlobal.logging.post_warning(self, "Invalid DataType")
			return 0

func _save_csv_data(resource_data: Dictionary[String, Dictionary], csv_data: CSVData) -> void:
	var file_path : String = csv_data.source_csv_path
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	var i : int = 0
	for data in resource_data.values():
		if i == 0:
			file.store_csv_line(data.keys() as PackedStringArray)
		else:
			file.store_csv_line(data.values() as PackedStringArray)
		i += 1
	file.close()
#endregion
