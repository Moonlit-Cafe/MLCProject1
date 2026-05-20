## A small packet of data for determining the positions or the "shape" of an
## action's occurance.
class_name ActionShape extends Resource

#region Declaration
@export var shape_name : StringName ## The name of the shape
@export var shape_id : StringName ## The id of the shape, in snake_case
@export var shape_pos_arr : Array[Vector2i] ## The actual shape of the ActionShape in V2i Array
#endregion

#region Setups
func load_data(data: Dictionary) -> void:
	shape_name = data.get("name")
	shape_pos_arr = data.get("shape_array")

func save_data() -> Dictionary:
	return {
		"name": shape_name,
		"shape_array": shape_pos_arr
	}
#endregion
