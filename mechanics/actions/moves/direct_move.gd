class_name DirectMove extends Move
## Class for direct movement. In other words, the thing being moved will end up at a specific tile, based on map coords, not based on the thing's position.

#region Declarations
## This is the tile that will be moved to. It is relative to whatever source effect's tile is. (Eg, V3.Zero would mean travelling to the effect's source tile)
@export var move_displace : Vector3
#endregion

#region Events
## Attempts to move the source to this tile, relative to the target. If that tile isn't available, it moves to the farthest tile in that direction, before it would see an entity.
func apply(target_tile: BattleTile, moving_entity:TileEntity) -> void:
	var value :BasicTile = moving_entity.tile.linked_tile
	var map : GameTileMap = value.tile_map
	var pos: Vector3 = map.get_tile_position(target_tile.linked_tile)
	
	pos += move_displace
	var new : BattleTile = map.get_battle_tile_at_position(pos)
	print(new == moving_entity.tile)
	new.add_entity(moving_entity)

	Global.logs.post_message(moving_entity, \
	"%s moved directly. Originally %s, now %s" \
	% [moving_entity, value.tile_position, new.linked_tile.tile_position])
#endregion
