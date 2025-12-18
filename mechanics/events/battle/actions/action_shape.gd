## A small packet of data for determining the positions or the "shape" of an
## action's occurance.
class_name ActionShape extends Resource

#region Declaration
@export var shape_id : StringName ## The id of the shape, in snake_case
@export var shape_pos_arr : Array[Vector2i] ## The actual shape of the ActionShape in V2i Array
@export var action_range : int = 0 ## How far from the caster the Shape can be used
#endregion

#region Setups
## Programmatically defining the Shapes
func generate_shape(id: StringName, pos_arr: Array[Vector2i], a_range: int) -> void:
	shape_id = id
	shape_pos_arr = pos_arr
	action_range = a_range
#endregion
