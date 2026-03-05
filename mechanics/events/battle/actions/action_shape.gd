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
	var dmh = DataManipulationHelper.new()
	shape_pos_arr = dmh.detect_special_data(data.get("shape_array"))

func save_data() -> Dictionary:
	var dmh = DataManipulationHelper.new()
	return {"shape_array": dmh.encode_special_data(shape_pos_arr)}
#endregion
