class_name TileEntity extends Node2D

#region Declarations
@export var sprite : AnimatedSprite2D

var char : Variant
#endregion

#region Events
func update() -> void:
	if sprite:
		sprite.sprite_frames = char.frames
	
	position = Vector2(0., 8.) ## TODO: Need to either settle on an offset, or grab thie from Battle Map
#endregion
