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
@export var type : ActionType
@export var shape : ActionShape
#endregion

#region Events
static func create_action_data(data: Dictionary, new_id: String) -> BaseAction:
	var new_action := BaseAction.new()
	new_action.name = data.get("name")
	new_action.id = new_id
	var new_shape : ActionShape = GlobalResources.get_data(GlobalResources.DataType.ACTION_SHAPE, data.get("shape"))
	print(new_shape.pos_arr)
	new_action.shape = new_shape
	return new_action
#endregion
