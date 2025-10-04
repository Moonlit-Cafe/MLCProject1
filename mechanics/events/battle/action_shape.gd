## A small packet of data for determining the positions or the "shape" of an
## an action's occurance.
class_name ActionShape extends Resource

#region Declaration
@export var shape_id : StringName
@export var shape_pos_arr : Array[Vector2i]
@export var action_range : int = 0
#endregion

#region Setups
func generate_shape(id: StringName, pos_arr: Array[Vector2i], a_range: int) -> void:
	shape_id = id
	shape_pos_arr = pos_arr
	action_range = a_range
#endregion
