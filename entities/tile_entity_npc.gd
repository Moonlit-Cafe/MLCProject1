class_name TileEntityNPC extends TileEntity

#region Declarations
var action_set : ActionSet
#endregion

#region Events
## For an AI to take their turn.
func take_turn() -> void:
	if action_set == null:
		Global.logs.post_warning(self, "Cannot take a turn without an ActionSet.")
		return
	var actions : ActionArray = action_set.check_condition(self)
	if ai == null:
		Global.logs.post_warning(self, "Cannot take a turn without a DecisionMaker.")
		return
	var decided_action : AIAction = ai.decide_action(actions)
	if decided_action == null:
		Global.logs.post_warning(self, "No action was decided for this turn.")
		return
	Global.logs.post_message(self, "Took action %s" % decided_action)

func load_data(data: Dictionary) -> void:
	action_set = data.get(&"action_set")

func save_data() -> Dictionary[StringName, Variant]:
	var dict := super()
	dict.set(&"action_set", action_set)
	return dict
#endregion
