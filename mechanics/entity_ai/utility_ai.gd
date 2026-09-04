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
		return
	
	# Loop through all the actions and score the actions.
	
	# Score action by looping through the considerations of each action, scoring the considerations
	# then average the consideration scores to get the action score.
	
	for action: AIAction in actions.actions:
		var score : float = 0.0
		for consideration: Consideration in action.considerations:
			score += consideration.score(entity)
		
		score = score / action.considerations.size()
		action.score = score
	
	var best_score : float = 0
	var best_action : AIAction = null
	for action: AIAction in actions.actions:
		if action.score > best_score:
			best_score = action.score
			best_action = action
	return best_action
#endregion
