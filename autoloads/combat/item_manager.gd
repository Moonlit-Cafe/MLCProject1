## Autoload in charge of items' actions in combat.
class_name ItemManager extends Node

#region Declarations
@export_file("*.json") var usable_file : String
@export_file("*.json") var action_shapes : String
@export var set_compendium : Array[ItemSet]

var ac_shape_array : Array[ActionShape]
var all_usables : Array[Usable]
#endregion

#region Events
func _ready() -> void:
	_define_shapes()
	_define_actions()
	
	# Remove later
	PlayerManager.available_items.append(all_usables.get(0))
	
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
	if not usable_file:
		push_warning("@ItemManager: There is no path to usables.json")
		return
	
	var file = FileAccess.open(usable_file, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if not data:
		push_warning("@ItemManager: Something wrong with file format")
		return
		
	for usable in data.keys():
		var us := Usable.new()
		us.us_id = usable
		if attach_data(us, data.get(usable)):
			continue
			
		all_usables.append(us)
#endregion


#region Helpers
func find_shape(shape_id: StringName) -> ActionShape:
	for shape in ac_shape_array:
		if shape.shape_id == shape_id:
			return shape
	
	return null
	
func attach_data(usable, us_data):
	usable.us_id = usable.us_id
	usable.us_name = us_data.get("name")
	var shape = find_shape(us_data.get("shape"))
	if not shape:
		push_warning("@ItemManager: There is no shape of id: %s" % us_data.get("shape"))
		return
	usable.shape = find_shape(us_data.get("shape"))
	usable.value = us_data.get("value")
#endregion
