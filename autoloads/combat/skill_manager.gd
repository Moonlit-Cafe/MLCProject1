## Handles all things related to skills.
class_name SkillManager extends Node

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
	PlayerManager.available_skills.append(all_actions.get(0))
	
	print("Initialized: SkillManager")

## Generates all the actions shapes available for action usage.
func _define_shapes() -> void:
	if not action_shapes:
		push_error("@SkillManager: There are no action shapes file attached")
		return
	var file = FileAccess.open(action_shapes, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if not data:
		push_warning("@SkillManager: Something is wrong with Shapes file format")
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
		push_warning("@SkillManager: There is no path to actions.json")
		return
	
	var file = FileAccess.open(action_file, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if not data:
		push_warning("@SkillManager: Something wrong with file format")
		return
	
	for skill in data.keys():
		var ac := Action.new()
		ac.ac_id = skill
		attach_data(ac, data.get(skill))
		
		all_actions.append(ac)
#endregion

#region Helpers
func find_shape(shape_id: StringName) -> ActionShape:
	for shape in ac_shape_array:
		if shape.shape_id == shape_id:
			return shape
	return null
	
	
func attach_data(skill, ac_data):
	skill.ac_name = ac_data.get("name")
	skill.damage_type = ac_data.get("damage_type") as Genum.DamageType
	var shape = find_shape(ac_data.get("shape"))
	if not shape:
		push_warning("@SkillManager: There is no shape of id: %s" % ac_data.get("shape"))
		return
	skill.shape = find_shape(ac_data.get("shape"))
	skill.value = ac_data.get("value")
#endregion
