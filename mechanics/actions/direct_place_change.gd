class_name DirectPlaceChange extends Change

#region Declarations
## The tile that the target will end up on. Has priority over diffs.
@export var move_direct : Vector3
#endregion

#region Events
## Attempts to move the source to this tile, relative to the target. If that tile isn't available, it moves to the farthest tile in that direction, before it would see an entity.
func apply(target:TileEntity) -> void:
	var value = target.tile.linked_tile
	
	#target.tile.linked_tile = get_nodepositiondoohickey_at(move_direct)
	#
	#global.logs.send_message(null, \
	#"%s moved directly. Originally %s, now %s" \
	#% [target, value.tile_position, target.tile.linked_tile.tile_position])
#endregion
