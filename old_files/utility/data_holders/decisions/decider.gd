## Handles the data in regards to a decision and provides info to higher hierarchies.
class_name Decider extends Resource

#region Declarations
@export var action : StringName ## The id of the action associated with this decision
@export var response : Curve ## The response curve for decision evaluation
@export var mod : float = 1 ## The modifier to the result of the response value
#endregion

#region Events
@warning_ignore_start("integer_division")
## Takes a [TileEntity] via [param unit] to be evaluated against with the [param target_stat]
## returns the resulting decision score based on [member response]
func score(unit: TileEntity, target_stat: Genum.StatType) -> float:
	if not response:
		return -1.
	
	print(unit)
	return response.sample_baked(unit.stats.get(target_stat, 0.) * mod)
@warning_ignore_restore("integer_division")
#endregion
	
