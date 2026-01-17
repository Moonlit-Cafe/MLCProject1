class_name CharacterResource extends Resource

#region Declarations
@export var o_name : StringName = &"" ## Name of the character
@export var stats : Dictionary[Genum.StatType, float] = {
	Genum.StatType.HEALTH: 10.
}
@export var frames : SpriteFrames
@export var decision_set : DeciderSet
#endregion

#region Events
func init() -> void:
	_build_stats()

func _build_stats(new_stats: Dictionary[Genum.StatType, float] = {}) -> void:
	stats.merge(new_stats, true)
#endregion
