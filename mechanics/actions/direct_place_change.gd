class_name DirectPlaceChange extends Change
## Class for direct movement. In other words, the thing being moved will end up at a specific tile, based on map coords, not based on the thing's position.

#region Declarations
## This is the tile that will be moved to. It is relative to whatever source effect's tile is. (Eg, V3.Zero would mean travelling to the effect's source tile)
@export var move_direct : Vector3
#endregion

#region Events
## Attempts to move the source to this tile, relative to the target. If that tile isn't available, it moves to the farthest tile in that direction, before it would see an entity.
func apply(target:TileEntity) -> void:
	# TYLER doing this backwards.
	# target should be battletile
	# apply can sort logic for if tthere is an entity
		# or for stat changes, maybe can be handled in the battleaction apply()
	# TODO PlaceChanges should be a different class, Move? So that apply can have different vars
	# Or place change should have a different class?
	var value = target.tile.linked_tile
	
	#target.tile.linked_tile = get_nodepositiondoohickey_at(move_direct)
	#
	#global.logs.send_message(null, \
	#"%s moved directly. Originally %s, now %s" \
	#% [target, value.tile_position, target.tile.linked_tile.tile_position])
#endregion
