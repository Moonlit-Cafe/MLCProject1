class_name DirectPlaceChange extends Change

#region Declarations
## The tile that the target will end up on. Has priority over diffs.
@export var move_direct : Vector3
#endregion

#region Events
## Attempts to move the source to this tile, relative to the target. If that tile isn't available, it moves to the farthest tile in that direction, before it would see an entity.
func apply(target) -> void:
	pass
#endregion
