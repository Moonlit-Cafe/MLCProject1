## Handles all the data in regards to an item.
class_name BasicItem extends Resource

#region Declarations
enum Tags {
	MATERIAL
}

@export var name : StringName = &""
@export var id : StringName = &""
@export var icon : Texture2D = null
@export var description : String = ""
@export var stack_size : int = 1
@export var tags : Array[Tags] = [Tags.MATERIAL]

var recipes : Array[StringName] = []
#endregion
