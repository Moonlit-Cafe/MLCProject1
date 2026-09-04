class_name TileEntityPlayer extends TileEntity

#region Declarations
func ready() -> void:
	add_to_group(&"friendlies")
	add_to_group(&"player")
#endregion
