class_name BaseAction extends Resource

#region Declarations
enum ActionType {
	ATTACK,
	BUFF,
	HEAL,
	MOVE
}

@export var name : StringName
@export var id : StringName
@export var shape : ActionShape
#endregion

#region Events
static func create_action_data(data: Dictionary, new_id: String) -> BaseAction:
	var new_action := BaseAction.new()
	new_action.name = data.get("name")
	new_action.id = new_id
	new_action.shape = GlobalResources.get_data(GlobalResources.DataType.ACTION_SHAPE, data.get("shape"))
	return new_action
#endregion
