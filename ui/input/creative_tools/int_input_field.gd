class_name IntInputField extends HBoxContainer

#region Declarations
@export var label_text : String = "" :
	set(value):
		if label:
			label.text = value.to_pascal_case()
		label_text = value

@onready var line_edit : LineEdit = $LineEdit
@onready var label : Label = $Label

var rgx := RegEx.new()
var old_text : String = ""
#endregion

#region Events
func _ready() -> void:
	rgx.compile("[^0-9]*$")
	line_edit.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	
	line_edit.text_changed.connect(_on_text_changed)
	
	label.text = label_text

func set_data(value: int) -> void:
	line_edit.text = "%s" % value

func get_data() -> int:
	return line_edit.text.to_int()
#endregion

#region Signal Callbacks
func _on_text_changed(new_text: String) -> void:
	if rgx.search(new_text):
		line_edit.text = new_text
		old_text = line_edit.text
	else:
		line_edit.text = old_text
	
	line_edit.caret_column = line_edit.text.length()
#endregion
