class_name CharacterResource extends Resource

#region Declarations
@export var o_name : StringName = &"" ## Name of the character
@export var stats : Dictionary[StringName, float] = {
	&"hp": 10.
}
@export var frames : SpriteFrames
#endregion

#region Events
func init() -> void:
	_build_stats()

func _build_stats(new_stats: Dictionary[StringName, float] = {}) -> void:
	stats.merge(new_stats, true)
#endregion
