class_name VectorInputField extends HBoxContainer

#region Declarations
@onready var x_input : IntInputField = $XInputField
@onready var y_input : IntInputField = $YInputField


#endregion

#region Events
func set_data(data: Vector2i) -> void:
	x_input.set_data(data.x)
	y_input.set_data(data.y)

func get_data() -> Vector2i:
	return Vector2i(x_input.get_data(), y_input.get_data())
#endregion
