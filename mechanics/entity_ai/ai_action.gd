class_name AIAction extends Resource

#region Declarations
@export var id : StringName = ""
@export var considerations : Dictionary[Target, ConsiderationSet] = {}
@export var target : Target
@export var action : BaseAction
var score : float = 0.0
#endregion

#region Events
# TODO: Can make the formula more complex later, but for now, just average out.
func score_action() -> void:
	if considerations.size() == 0:
		return
	
	var score_idx : int = 0
	for target_type in considerations.keys():
		var score_target = target_type.locate()
		for consider in considerations.get(target_type).considerations:
			if not consider.supports(score_target):
				continue
			score += consider.score(score_target)
			score_idx += 1
	
	score = score / score_idx
#endregion
