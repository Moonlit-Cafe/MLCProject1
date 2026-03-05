extends CanvasLayer

#region Signal Callbacks
func _on_exit_pressed() -> void:
	queue_free()
#endregion
