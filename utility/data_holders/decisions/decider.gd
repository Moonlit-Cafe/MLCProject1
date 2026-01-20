## Handles the data in regards to a decision and provides info to higher hierarchies.
class_name Decider extends Resource

#region Declarations
@export var action : StringName
@export var target_stat := Genum.StatType.HEALTH
@export var response : Curve
@export var mod : float = 1
#endregion

#region Events
@warning_ignore_start("integer_division")
func score(unit: TileEntity) -> float:
	if not response:
		return -1.
	
	print(unit)
	return response.sample_baked(unit.stats.get(target_stat, 0.) * mod)
@warning_ignore_restore("integer_division")
#endregion
	
