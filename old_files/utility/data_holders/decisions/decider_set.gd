## Handles ALL the data in regards to decisions, contains a dictionary whose keys are [enum Genum.TargetType], and 
## values are [DeciderArray].
class_name DeciderSet extends Resource

#region Declaration
@export var decisions : Dictionary[Genum.TargetType, DeciderArray] = {} ## The full set of available decisions

var caller : TileEntity ## The [TileEntity] utilizing [member decisions]
#endregion

#region Events
## Initiates this DecisionSet based on the origin entity
func init(entity: TileEntity) -> void:
	caller = entity

## Grabs the correct [TileEntity] based on [enum Genum.TargetType]
func get_target(target_type: Genum.TargetType) -> TileEntity:
	if not caller:
		push_warning("DeciderSet: Need a caller to continue...")
		return null
	
	match(target_type):
		Genum.TargetType.SELF:
			return caller
		Genum.TargetType.PLAYER:
			return PlayerManager.entity_ref
		_:
			return null

## Grabs the decision the [member caller] should take, grabbing the best decisions of the
## [DeciderArray]s and then comparing those scores
func get_decision() -> DecisionPacket:
	var decision_results : Array[DecisionPacket] = []
	for target_type in decisions.keys():
		var target = get_target(target_type)
		var decision_list : DeciderArray = decisions.get(target_type)
		decision_results.append(decision_list.get_best_decision(target))
	
	var top_result : DecisionPacket = null
	for result in decision_results:
		if not top_result:
			top_result = result
		if result.score > top_result.score:
			top_result = result
	
	return top_result
#endregion
