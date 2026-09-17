class_name BaseAction extends Resource

#region Declarations
@export var name : StringName
@export var description : String
@export var shape : ActionShape
@export var attack_range : int = 1
@export var t_cost := TimeCost.create(Genum.TimeType.TURN, 1)
#endregion

#region Events
# TODO: Edit the ResourceLoader to reflect new declarations
static func create_action_data(data: Dictionary) -> BaseAction:
	var new_action := BaseAction.new()
	new_action.name = data.get("name")
	var new_shape : ActionShape = GlobalResources.get_data(GlobalResources.DataType.ACTION_SHAPE, data.get("shape"))
	print(new_shape.pos_arr)
	new_action.shape = new_shape
	return new_action
#endregion

#
