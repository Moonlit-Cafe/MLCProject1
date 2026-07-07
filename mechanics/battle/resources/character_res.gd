class_name Character extends Resource

#region Declarations
@export var name : StringName = &"" ## Name of the character.
@export var stats : Dictionary[Genum.StatType, float] = {
	Genum.StatType.HEALTH: 10.
}
@export var frames : SpriteFrames ## The frames representing the 2D character.
#endregion

#region Events
func init() -> void:
	_build_stats()

func _build_stats(new_stats: Dictionary[Genum.StatType, float] = {}) -> void:
	stats.merge(new_stats, true) 
#endregion
