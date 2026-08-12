## Handles all the data in regards to an item.
class_name ItemResource extends Resource

#region Declarations
enum Tags {
	MATERIAL
}

@export var name : StringName = &""
@export var id : StringName = &""
@export var icon : Texture2D = null
@export var description : String = ""
@export var stack_size : int = 1
@export var tags : Array[Tags] = []
#endregion

#region Events
func set_data(dict: Dictionary, given_id: StringName) -> void:
	name = dict.get(&"name")
	id = given_id
	var icon_pos : Vector2 = GlobalResources.load_custom_data(dict.get(&"icon_pos"),
		GlobalResources.CustomDataType.VECTOR)
	icon = GlobalResources.tex_loader.grab_item_texture(&"items", icon_pos)
	description = dict.get(&"description")
	stack_size = dict.get(&"stack_size")
#endregion
