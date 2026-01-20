## Holds the data for an entire set of decisions in regards to a single target type.
class_name DeciderArray extends Resource

#region Declarations
@export var decision_list : Array[Decider] = []
#endregion

#region Events
func get_score_of(idx: int, entity: TileEntity) -> float:
	if idx >= decision_list.size():
		push_warning("DeciderArray: Index of %s is above the available count of %s" % [idx, decision_list.size()])
		return 0.
	
	var decider : Decider = decision_list.get(idx)
	return decider.score(entity)

func get_best_decision(entity: TileEntity) -> DecisionPacket:
	print("Scoring . . . ")
	
	var packet := DecisionPacket.new()
	packet.target = entity
	
	if decision_list.size() == 0:
		push_warning("DeciderArray: There are no decisions in the list.")
		return packet
	
	for i in range(decision_list.size()):
		if not packet.decision and packet.score == 0.:
			packet.decision = decision_list.get(0)
			continue
		
		var score : float = get_score_of(i, entity)
		if score > packet.score:
			packet.decision = decision_list.get(i)
			packet.score = score
	
	return packet
#endregion
