class_name RelativePlaceChange extends Change

#region Declarations
## The tile that the target will end up on. Has priority over diffs.
@export var direction : Vector3
@export var magnitude : int = -1
#endregion

#region Events
func apply(target) -> void:
	pass
#endregion
