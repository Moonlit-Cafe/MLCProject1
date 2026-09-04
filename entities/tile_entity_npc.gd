class_name TileEntityNPC extends TileEntity

#region Declarations
var action_set : ActionSet
#endregion

#region Events
## For an AI to take their turn.
func take_turn() -> void:
	var actions : ActionArray = action_set.check_condition(self)
	var decided_action : AIAction = ai.decide_action(actions)
	Global.logs.post_message(self, "Took action %s" % decided_action)

func load_data(data: Dictionary) -> void:
	action_set = data.get(&"action_set")

func save_data() -> Dictionary[StringName, Variant]:
	var dict := super()
	dict.set(&"action_set", action_set)
	return dict
#endregion
