class_name ObstacleObject extends Resource

#region Declarations
@export var o_name : StringName ## The name of the obstacle type
@export var frames : SpriteFrames ## The sprites used for the obstacle (might introduce animated ones later)
## The general stats for the obstacle
@export var stats : Dictionary[StringName, int] = {
	&"hp": 10,
	&"defense": 0,
}
#endregion

#region Events
## IDEA: Potentially move this into TileEntity for generalization with TileEnemy

## Similar to the Enemy, calculates the defense value of the obstacle
func defend(ac: Action) -> int:
	var attack_value := int(ac.value)
	# TODO: Differentiate between magic attacks and physical attacks.
	return attack_value - stats.get(&"defense")
#endregion
