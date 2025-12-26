class_name PlayerEntity extends TileEntity

#region Declarations
#endregion

#region Events
func update() -> void:
	if sprite:
		sprite.sprite_frames = char.frames
	
	position = Vector2(0., 8.) ## TODO: Need to either settle on an offset, or grab thie from Battle Map
#endregion

#region Processes
#endregion

#region Helpers
#endregion

#region Signal Callbacks
#endregion
