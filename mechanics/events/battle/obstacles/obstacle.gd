class_name ObstacleObject extends CharacterResource

#region Declarations
## The general stats for the obstacle
@export var obstacle_stats : Dictionary[StringName, float] = {
	&"hp": 10.,
	&"defense": 0.,
}
#endregion

#region Events
func init() -> void:
	super()
	_build_stats(obstacle_stats)
## IDEA: Potentially move this into TileEntity for generalization with TileEnemy

## Similar to the Enemy, calculates the defense value of the obstacle
func defend(ac: Action) -> int:
	var attack_value := int(ac.value)
	# TODO: Differentiate between magic attacks and physical attacks.
	return attack_value - stats.get(&"defense")
#endregion
