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
func score_action(origin: TileEntity) -> void:
	score = 0.0
	if considerations.is_empty():
		return
	
	var score_idx : int = 0
	for target_type : Target in considerations.keys():
		var score_target : TileEntity = target_type.locate(origin)
		if score_target == null:
			continue
		var consider_set : ConsiderationSet = considerations.get(target_type)
		if consider_set == null:
			continue
		for consider : Consideration in consider_set.considerations:
			if not consider.supports(score_target):
				continue
			score += consider.score(score_target)
			score_idx += 1
	
	if score_idx > 0:
		score = score / score_idx
#endregion
