class_name DirectMove extends Move
## Class for direct movement. In other words, the thing being moved will end up at a specific tile, based on map coords, not based on the thing's position.

#region Declarations
## This is the tile that will be moved to. It is relative to whatever source effect's tile is. (Eg, V3.Zero would mean travelling to the effect's source tile)
@export var move_displace : Vector3
#endregion

#region Events
## Attempts to move the source to this tile, relative to the target. If that tile isn't available, it moves to the farthest tile in that direction, before it would see an entity.
func apply(target_tile: BattleTile, moving_entity:TileEntity) -> void:
	# TODO how to get tile thats x & z away
	# target tile
	var value = moving_entity.tile.linked_tile
	# find a way to get the map from the tile
	var map = value.tile_map
	value = value.tile_position
	# if i can get the map
		# then get the current tiles xz pos
		# then get the tile at relatively xz position
	# then have the entity "move" over there
	#target.tile.linked_tile = get_nodepositiondoohickey_at(move_direct)


	#global.logs.send_message(null, \
	#"%s moved directly. Originally %s, now %s" \
	#% [target, value.tile_position, target.tile.linked_tile.tile_position])
#endregion
