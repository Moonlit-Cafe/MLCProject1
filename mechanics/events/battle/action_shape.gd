## A small packet of data for determining the positions or the "shape" of an
## an action's occurance.
class_name ActionShape extends Resource

#region Declaration
@export var shape_id : StringName
@export var shape_pos_arr : Array[Vector2i]
@export var range : int = 0
#endregion
