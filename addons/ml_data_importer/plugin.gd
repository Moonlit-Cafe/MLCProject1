@tool
extends EditorPlugin

const PLUGIN_NAME = "ml_data_importer"

func _enter_tree() -> void:
	EditorInterface.set_plugin_enabled(PLUGIN_NAME + "/csv_import", true)


func _exit_tree() -> void:
	EditorInterface.set_plugin_enabled(PLUGIN_NAME + "/csv_import", false)
