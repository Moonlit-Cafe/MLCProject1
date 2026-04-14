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
@export_file_path(".csv") var material_data_path : String
var material_data : CSVData
@export_file_path(".csv") var usable_data_path : String
var usable_data : CSVData
@export_file_path(".csv") var equippable_data_path : String
var equippable_data : CSVData
@export_file_path(".csv") var equipset_data_path : String
var equipset_data : CSVData
@export_file_path(".csv") var weapon_data_path : String
var weapon_data : CSVData
@export_category("Skill Data")
@export_file_path(".csv") var action_shape_data_path : String
var action_shape_data : CSVData
@export_file_path(".csv") var action_data_path : String
var action_data : CSVData
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
	print("Initializing: ResourceManager")
	load_data()

func load_data() -> void:
	_load_item_compendium()
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
	var id_type : StringName = &""
	var type_data : CSVData
	var item
	
	match(type):
		ItemType.MATERIAL:
			material_data = load(material_data_path)
			type_data = material_data
			id_type = &"MAT_%s"
			item = MaterialItem.new()
		ItemType.EQUIPPABLE:
			equippable_data = load(equippable_data_path)
			type_data = equippable_data
			id_type = &"EQP_%s"
			item = EquippableItem.new()
		_:
			push_warning("@ResourceManager: The given ItemType is incorrect, returning empty dictionary.")
			return {}
			
	if not type_data:
		push_warning("@ResourceManager: There is no connected %s data file, skipping...", type)
		return {}
	
	var i : int = 0
	var data = type_data.records
	for item_dat in data:
		item = item.duplicate()
		item.i_name = item_dat.get("id")
		item.id = id_type % i
		item.load_data(item_dat)
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

func _save_item_compendium() -> void:
	var material_dict : Dictionary[String, Dictionary] = {}
	var usable_dict : Dictionary[String, Dictionary] = {}
	var equippable_dict : Dictionary[String, Dictionary] = {}
	var weapon_dict : Dictionary[String, Dictionary] = {}
	for item in item_compendium.keys():
		var item_data = item_compendium.get(item).save_data()
		var item_name : String = item_compendium.get(item).i_name
		if "MAT" in item:
			material_dict.set(item_name, item_data)
		elif "USE" in item:
			usable_dict.set(item_name, item_data)
		elif "EQP" in item:
			equippable_dict.set(item_name, item_data)
		elif "WEP" in item:
			weapon_dict.set(item_name, item_data)
		else:
			push_error("@ResourceManager: Item's id type not found.")
	
	if material_data:
		_save_csv_data(material_dict, material_data)
	
	if usable_data:
		_save_csv_data(usable_dict, usable_data)
	
	if equippable_data:
		_save_csv_data(equippable_dict, equippable_data)
	
	if weapon_data:
		_save_csv_data(weapon_dict, weapon_data)
#endregion

#region Action Compendiums
func _load_action_shapes() -> void:
	action_shape_data = load(action_shape_data_path)
	
	print("Loading: ActionShapes")
	if not action_shape_data:
		push_warning("@ResourceManager: There is no connected action_shape data file, skipping...")
		return
	
	var i : int = 0
	var data := action_shape_data.records
	for shape in data:
		var action_shape := ActionShape.new()
		action_shape.shape_id = "ACS_%s" % i
		action_shape.shape_name = shape.get("id")
		action_shape.load_data(shape)
		add_action_shape(action_shape)
		i += 1
	print("Loaded: ActionShapes")

func _load_actions() -> void:
	action_data = load(action_data_path)
	
	print("Loading: Actions")
	if not action_data:
		push_warning("@ResourceManager: There is no connected action data file, skipping...")
		return
	
	var i : int = 0
	var data := action_data.records
	for action_dat in data:
		var action := CombatAction.new()
		action.ac_id = "ACT_%s" % i
		action.ac_name = action_dat.get("id")
		action.load_data(action_dat)
		add_action(action)
		i += 1
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
	if not action_shape_data:
		push_warning("@ResourceManager: There is no ActionShape data linked to save to...")
		return
	
	var action_shape_dict : Dictionary[String, Dictionary] = {}
	for shape in action_shape_compendium.values():
		print("Saving %s with array %s" % [shape.shape_name, shape.shape_pos_arr])
		action_shape_dict.set(shape.shape_name, shape.save_data())
	
	_save_csv_data(action_shape_dict, action_shape_data)

func _save_actions() -> void:
	if not action_data:
		push_warning("@ResourceManager: There is no Action data linked to save to...")
		return
	
	var action_dict : Dictionary[String, Dictionary] = {}
	for action in action_compendium.values():
		action_dict.set(action.ac_name, action.save_data())
	
	_save_csv_data(action_dict, action_data)
#endregion

#region Set Compendium
func _load_set_compendium() -> void:
	equipset_data = load(equipset_data_path)
	
	var equip_set = EquipSet.new()
	var data = equipset_data.records
	
	for cur_set in data:
		equip_set = equip_set.duplicate()
		equip_set.load_data(data[cur_set.get("set_id")], "set_id")
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
