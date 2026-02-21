class_name VectorInputField extends HBoxContainer

#region Declarations
@onready var x_input : LineEdit = $XInput
@onready var y_input : LineEdit = $YInput

var rgx := RegEx.new()
var xold_text : String = ""
var yold_text : String = ""
#endregion

#region Events
func _ready() -> void:
	rgx.compile("^[0-9]*$")
	x_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	y_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	
	x_input.text_changed.connect(_on_text_changed.bind(x_input))
	y_input.text_changed.connect(_on_text_changed.bind(y_input))

func set_data(data: Vector2i) -> void:
	x_input.text = "%s" % data.x
	y_input.text = "%s" % data.y

func grab_data() -> Vector2i:
	return Vector2i(x_input.text.to_int(), y_input.text.to_int())
#endregion

#region Signal Callbacks
func _on_text_changed(new_text: String, line_edit: LineEdit) -> void:
	if rgx.search(new_text):
		line_edit.text = new_text
		if line_edit == x_input:
			xold_text = line_edit.text
		else:
			yold_text = line_edit.text
	else:
		if line_edit == x_input:
			line_edit.text = xold_text
		else:
			line_edit.text = yold_text
	
	line_edit.caret_column = line_edit.text.length()
#endregion
