class_name AttackAction extends CombatAction
# HACK Do we need this if we have Battle Action and the Registry?

#region Declarations
#endregion

#region Events
static func create_attack_action_data(data: Dictionary) -> AttackAction:
	var new_action := BaseAction.create_action_data(data) as AttackAction
	return new_action
#endregion
