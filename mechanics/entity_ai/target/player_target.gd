class_name PlayerTarget extends Target

#region Events
func locate(origin: TileEntity) -> TileEntity:
	var player : TilePlayer = origin.get_tree().get_first_node_in_group(&"player")
	return player
#endregion
