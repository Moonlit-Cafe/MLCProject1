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



# TODO implement this
# have battle map populate this guy into a tile
	#what is spawning the enemies
	# how does it decide what to spawn
	# and where
	# make an additional spawn
	# set it to center column, bottom row
# use arrows to move for now
	# movin	is moving data to target tile
	# the clearing OG parent tile
# Selectability of tiles should be decided by where the player is, instead of the bottom row of the map
	# find where selectability is decided
	# chang eit to find the tile with player?
	# then base it off of that? Somehow?
	# what about verticality?
