class_name DisplayManager extends Node

#region Declarations
var current_resolution : Vector2i :
	set(value):
		change_resolution(current_resolution)
		current_resolution = value
#endregion

#region Events
func _ready() -> void:
	current_resolution = get_tree().root.size
	print(get_tree().root.size)

func change_resolution(new_resolution: Vector2i) -> void:
	get_tree().root.size = new_resolution
#endregion
