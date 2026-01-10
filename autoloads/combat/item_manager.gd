## Autoload in charge of items' actions in combat.
class_name ItemManager extends Node

#region Declarations
@export_file("*.json") var action_file : String
@export_file("*.json") var action_shapes : String
@export var set_compendium : Array[ItemSet]

var ac_shape_array : Array[ActionShape]
var all_actions : Array[Action]
#endregion

#region Events
func _ready() -> void:
	_define_shapes()
	_define_actions()
	
	# Remove later
	PlayerManager.available_items.append(all_actions.get(0))
	
	print("Initialized: ItemManager")


## Generates all the actions shapes available for action usage.
func _define_shapes() -> void:
	if not action_shapes:
		push_error("@ItemManager: There are no action shapes file attached")
		return
	var file = FileAccess.open(action_shapes, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if not data:
		push_warning("@ItemManager: Something is wrong with Shapes file format")
		return
	
	# Single Target Shape Definition
	for shape in data.keys():
		var shape_data = data.get(shape)
		
		var new_shape := ActionShape.new()
		var id = shape_data.get("id")
		var positions : Array[Vector2i] = []
		for position in shape_data.get("positions"):
			positions.append(Vector2i(int(position.get(0)), int(position.get(1))))
		var a_range = shape_data.get("range")
		new_shape.generate_shape(id, positions, a_range)
	
		# Start adding in all the shapes
		ac_shape_array.append(new_shape)

	
## After generating the action shapes, this method generates the actions themselves from file.
func _define_actions() -> void:
	if not action_file:
		push_warning("@ItemManager: There is no path to usables.json")
		return
	
	var file = FileAccess.open(action_file, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if not data:
		push_warning("@ItemManager: Something wrong with file format")
		return
		
		
	for usable in PlayerManager.get_usables():
		var us = Action.new()
		attach_data(us, data.get(usable))
		
		all_actions.append(us)
#endregion


#region Helpers
func find_shape(shape_id: StringName) -> ActionShape:
	for shape in ac_shape_array:
		if shape.shape_id == shape_id:
			return shape
	
	return null
	
func attach_data(usable, us_data):
	us.us_id = usable.item_id
	us.us_name = us_data.get("name")
	us.damage_type = us_data.get("damage_type") as Genum.DamageType
	var shape = find_shape(us_data.get("shape"))
	if not shape:
		push_warning("@ItemManager: There is no shape of id: %s" % us_data.get("shape"))
		return
	us.shape = find_shape(us_data.get("shape"))
	us.value = us_data.get("value")
#endregion
