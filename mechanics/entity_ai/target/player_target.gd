class_name PlayerTarget extends Target

#region Events
func locate(origin: TileEntity) -> TileEntity:
	if origin == null or origin.get_tree() == null:
		return null
	var player : TileEntity = origin.get_tree().get_first_node_in_group(GroupNames.PLAYER)
	return player
#endregion
