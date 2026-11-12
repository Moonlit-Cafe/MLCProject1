## Data pertaining to the Enemy Character Type
class_name EnemyCharacter extends BaseCharacter

#region Declarations
enum EnemyType {
	NULL
}

@export var actions : ActionArray
@export var tags : Array[EnemyType] = [EnemyType.NULL]
#endregion

#region Events
func consider_actions(origin: TileEntity) -> AIAction:
	if actions == null or actions.actions.is_empty():
		Global.logs.post_warning(origin, "This enemy has no actions to consider.")
		return null
	
	var top_score : AIAction = actions.pick_action(origin)
	if top_score == null:
		Global.logs.post_warning(origin, "No action could be scored.")
		return null
	
	Global.logs.post_message(origin, "Action %s got top score of %s!" % [top_score.id, top_score.score])
	return top_score
#endregion
