class_name CharacterResource extends Resource

#region Declarations
@export var o_name : StringName = &"" ## Name of the character
@export var stats : Dictionary[Genum.StatType, float] = {
	Genum.StatType.HEALTH: 10.
}
@export var frames : SpriteFrames ## The frames representing the 2D character
@export var decision_set : DeciderSet ## The decision set used for the character's considerations
#endregion

#region Events
## Sets up the initial settings for the Entity
func init() -> void:
	_build_stats()

## Builds up the stats based on [member stats] and a new set of stats given by [param new_stats]
func _build_stats(new_stats: Dictionary[Genum.StatType, float] = {}) -> void:
	stats.merge(new_stats, true)
#endregion
