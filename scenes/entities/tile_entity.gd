class_name TileEntity extends Node2D

#region Declarations
@export var sprite : AnimatedSprite2D

var char : Variant


var hp : int = -1 :
	set(value):
		#if not held_entity:
			#return
		
		if value <= 0:
			# PLANNED setup signal instead of double get_parent() call
			get_parent().get_parent().clear_object()
			hp = -1
		else:
			hp = value
var max_hp : int = 0
#endregion

#region Events
func update() -> void:
	if sprite:
		sprite.sprite_frames = char.frames
	
	position = Vector2(0., 8.) ## TODO: Need to either settle on an offset, or grab thie from Battle Map
	
func get_hp() -> Vector2i:
	return Vector2i(hp, max_hp)
#endregion
