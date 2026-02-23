## Handles the creation of various UI components for the Creative Tools System
class_name CreativeUIGenerator

#region Declarations
static var enum_array_field_scene : String = "res://ui/input/creative_tools/enum_menu_button.tscn"
static var int_input_field_scene : String = "res://ui/input/creative_tools/int_input_field.tscn"
static var vector_input_field_scene : String = "res://ui/input/creative_tools/vector_input_field.tscn"
#endregion

#region Events
static func create_enum_array_field() -> EnumMenuButton:
	var enum_field_scene : PackedScene = ResourceLoader.load(enum_array_field_scene)
	var enum_field : EnumMenuButton = enum_field_scene.instantiate()
	return enum_field

static func create_int_field() -> IntInputField:
	var int_field_scene : PackedScene = ResourceLoader.load(int_input_field_scene)
	var int_field : IntInputField = int_field_scene.instantiate()
	return int_field

## Creates an input field for vector based data.
static func create_vector_field() -> VectorInputField:
	var vec_field_scene : PackedScene = ResourceLoader.load(vector_input_field_scene)
	var vec_field : VectorInputField = vec_field_scene.instantiate()
	#vec_field.set_data(data)
	return vec_field
#endregion
