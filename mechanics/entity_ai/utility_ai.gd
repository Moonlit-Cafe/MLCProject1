class_name UtilityAI extends DecisionMaker

#region Declarations
var entity : TileEntity
#endregion

#region Events
func init(en: TileEntity) -> void:
	entity = en

func decide_action(actions: ActionArray) -> AIAction:
	if not entity:
		Global.logs.post_warning(self, "There is no entity referenced to give action decision to.")
		return null
	
	# Loop through all the actions and score the actions.
	
	# Score action by looping through the considerations of each action, scoring the considerations
	# then average the consideration scores to get the action score.
	
	if actions == null or actions.actions.is_empty():
		Global.logs.post_warning(self, "No actions were given to decide between.")
		return null
	
	var best_action : AIAction = actions.pick_action(entity)
	return best_action
#endregion
