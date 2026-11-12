class_name TileEntityPlayer extends TileEntity

#region Declarations
func _ready() -> void:
	add_to_group(GroupNames.FRIENDLIES)
	add_to_group(GroupNames.PLAYER)
#endregion
