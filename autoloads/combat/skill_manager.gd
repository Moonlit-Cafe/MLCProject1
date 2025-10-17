## Handles all things related to skills.
extends Node

#region Declarations
@export_file("*.json") var action_file : String
@export var set_compendium : Array[ItemSet]

var ac_shape_array : Array[ActionShape]
var all_actions : Array[Action]
#endregion

#region Built-Ins
func _ready() -> void:
	_define_shapes()
	_define_actions()
	
	# Remove later
	PlayerManager.available_skills.append(all_actions.get(0))
#endregion

#region Setups
## Generates all the actions shapes available for action usage.
func _define_shapes() -> void:
	# Single Target Shape Definition
	var st_shape := ActionShape.new()
	st_shape.generate_shape(&"single_target", [Vector2i.LEFT,Vector2i.ZERO], 3)
	
	# Start adding in all the shapes
	ac_shape_array.append(st_shape)

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
		ac.ac_name = data.get(skill).get("name")
		ac.damage_type = data.get(skill).get("damage_type") as Genum.DamageType
		var shape = find_shape(data.get(skill).get("shape"))
		if not shape:
			push_warning("@SkillManager: There is no shape of id: %s" % data.get(skill).get("shape"))
			return
		ac.shape = find_shape(data.get(skill).get("shape"))
		ac.value = data.get(skill).get("value")
		
		all_actions.append(ac)
#endregion

#region Helpers
func find_shape(shape_id: StringName) -> ActionShape:
	for shape in ac_shape_array:
		if shape.shape_id == shape_id:
			return shape
	
	return null
#endregion
