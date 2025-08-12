# SceneManager.gd - Handles actual scene loading and transitions
extends Node

var prog_scene: ProgScene

@export var scene_paths : Dictionary[StringName, PackedScene] = {}

# AI: This is generated code, come back to it
#region AI Generated
func load_next_scene():
	var scene_data = prog_scene.generate_next_event()
	_load_scene(scene_data)

func _on_scene_changed(scene_type: String, scene_data: Dictionary):
	print("Scene changed to: ", scene_type, " with data: ", scene_data)

func _load_scene(scene_data: Dictionary):
	var scene_type = scene_data["scene_type"]
#endregion
