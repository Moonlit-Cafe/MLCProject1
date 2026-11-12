class_name ActionArray extends Resource

#region Declarations
@export var actions : Array[AIAction]
#endregion

#region Events
func pick_action(origin: TileEntity) -> AIAction:
	var chosen_action : AIAction = null
	for action : AIAction in actions:
		if action == null:
			continue
		action.score_action(origin)
		if chosen_action == null or action.score > chosen_action.score:
			chosen_action = action
	
	return chosen_action
#endregion
