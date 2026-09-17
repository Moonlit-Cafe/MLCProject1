class_name ActionShape extends Resource

#region Declarations
@export var name : StringName
@export var pos_arr : Array[Vector2i]
#endregion

#region Setups
static func create_shape_data(data: Dictionary) -> ActionShape:
	var new_shape := ActionShape.new()
	new_shape.name = data.get("name")
	var new_pos_arr : Array[Vector2i] = []
	for vec in data.get("pos_arr"):
		new_pos_arr.append(GlobalResources.load_custom_data(vec, GlobalResources.CustomDataType.VECTOR))
	new_shape.pos_arr = new_pos_arr
	return new_shape
#endregion
