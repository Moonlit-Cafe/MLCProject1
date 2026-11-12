extends DecisionMaker

#region Events
func init(_entity: TileEntity) -> void:
	pass

func decide_action(actions: ActionArray) -> AIAction:
	if actions == null or actions.actions.is_empty():
		return null
	return actions.actions.pick_random()
#endregion
