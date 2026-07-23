
extends CanvasLayer

#region Declarations
@export_file(".tscn") var creative_tools_scene : String = ""
#endregion

#region Events
func _ready() -> void:
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		if visible:
			hide()
		else:
			show()
#endregion

#region Signal Callbacks
func _on_creative_tools_pressed() -> void:
	if creative_tools_scene == "":
		return
	
	var creative_tools_p_scene : PackedScene = ResourceLoader.load(creative_tools_scene)
	var creative_tools : PanelContainer = creative_tools_p_scene.instantiate()
	add_child(creative_tools)
#endregion
