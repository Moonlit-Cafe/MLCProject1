## ActionSet is used to clump all available actions and 'tag' them based on an using entities
## condition. For example, a phase 2 set of attacks for a boss, or if an entity is in a "flee" state
## it could access more unique abilities.
class_name ActionSet extends Resource

#region Declarations
enum Conditions {
	DEFAULT
}

@export var sets : Dictionary[Conditions, ActionArray]
#endregion

#region Events
func pick_action(entity: TileEntity) -> AIAction:
	var action_array : ActionArray = check_condition(entity)
	if action_array == null or action_array.actions.is_empty():
		Global.logs.post_warning(entity, "No action set matched this entity's current condition.")
		return null
	return action_array.pick_action(entity)

func check_condition(_entity: TileEntity) -> ActionArray:
	return sets.get(Conditions.DEFAULT)

func size() -> int:
	var total : int = 0
	for condition : Conditions in sets.keys():
		var action_array : ActionArray = sets.get(condition)
		if action_array:
			total += action_array.actions.size()
	return total
#endregion
