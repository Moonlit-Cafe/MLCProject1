extends Node

#region Declarations
@export var map_data : ZoneData
#endregion

#region Events
func _ready() -> void:
	var new_timeline := Timeline.generate_timeline(map_data)
	add_child(new_timeline)
	new_timeline.grab_focus(true)
#endregion
