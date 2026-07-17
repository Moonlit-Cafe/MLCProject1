class_name ActionShape extends Resource

#region Declarations
@export var name : StringName
@export var id : StringName
@export var pos_arr : Array[Vector2i]
#endregion

#region Setups
static func create_shape_data(data: Dictionary, new_id: String) -> ActionShape:
	var new_shape := ActionShape.new()
	new_shape.name = data.get("name")
	new_shape.id = new_id
	new_shape.pos_arr = data.get("pos_arr")
	return new_shape
#endregion
