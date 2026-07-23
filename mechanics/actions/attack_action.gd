class_name AttackAction extends BaseAction

#region Declarations
#endregion

#region Events
static func create_attack_action_data(data: Dictionary, new_id: String) -> AttackAction:
	var new_action := BaseAction.create_action_data(data, new_id) as AttackAction
	return new_action
#endregion
