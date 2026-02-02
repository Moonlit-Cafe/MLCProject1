## Handles all things related to skills.
class_name SkillManager extends Node

#region Declarations
@export_file("*.json") var action_file : String ## All the available actions in the game
@export_file("*.json") var action_shapes : String ## All the Shapes that are required for actions

var ac_shape_array : Array[ActionShape] ## The array representing all the [ActionShape]s
var all_actions : Array[Action] ## The array holding all the made [Action]s
#endregion

#region Events
func _ready() -> void:
	_define_shapes()
	_define_actions()
	
	# Remove later
	for action in all_actions:
		PlayerManager.available_skills.append(action)
	
	print("Initialized: SkillManager")

## Generates all the [ActionShape]s available for action usage based on [member action_shapes].
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
		new_shape.generate_shape(id, positions)
	
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
		var ac := CombatAction.new()
		ac.ac_id = skill
		ac.ac_name = data.get(skill).get("name")
		ac.damage_type = data.get(skill).get("damage_type") as Genum.DamageType
		var shape = find_shape(data.get(skill).get("shape"))
		if not shape:
			push_warning("@SkillManager: There is no shape of id: %s" % data.get(skill).get("shape"))
			return
		ac.shape = find_shape(data.get(skill).get("shape"))
		ac.value = data.get(skill).get("value")
		ac.a_range = data.get(skill).get("range")
		
		all_actions.append(ac)

func get_action(id: StringName) -> CombatAction:
	for action in all_actions:
		if action.ac_id == id:
			return action
	return null
#endregion

#region Helpers
## Returns an appropriate [ActionShape] based on the id given by [member shape_id]
func find_shape(shape_id: StringName) -> ActionShape:
	for shape in ac_shape_array:
		if shape.shape_id == shape_id:
			return shape
	return null

## Used to attach data from actions onto a skill, typically for items.
func attach_data(skill, ac_data) -> bool: 
	skill.ac_name = ac_data.get("name")
	skill.damage_type = ac_data.get("damage_type") as Genum.DamageType
	var shape = find_shape(ac_data.get("shape"))
	if not shape:
		push_warning("@SkillManager: There is no shape of id: %s" % ac_data.get("shape"))
		return true
	skill.shape = find_shape(ac_data.get("shape"))
	skill.value = ac_data.get("value")
	return false
#endregion
