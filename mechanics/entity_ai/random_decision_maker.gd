extends DecisionMaker

#region Events
func decide_action(actions: Array[AIAction]) -> AIAction:
	return actions.pick_random()
#endregion
