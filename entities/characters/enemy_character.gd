## Data pertaining to the Enemy Character Type
class_name EnemyCharacter extends BaseCharacter

#region Declarations
enum EnemyType {
	NULL
}

@export var actions : Array[AIAction] = []
@export var tags : Array[EnemyType] = [EnemyType.NULL]
#endregion

#region Events
func consider_actions() -> void:
	var top_score : AIAction = null
	for action in actions:
		var target = null
		match(action.target):
			AIAction.Target.SELF:
				target = self
		
		if not target:
			continue
		
		if not top_score:
			top_score = action
		
		action.score_action(target)
		if action.score > top_score.score:
			top_score = action
	
	Global.logs.post_message(Global, "Action %s got top score of %s!" % [top_score.id, top_score.score])
#endregion
