class_name Balanced extends DecisionMaker

@export var cons : Array[Decider]

## TODO: always play balanced, default curves for considerations
func score(p_dict: Dictionary) -> float :
	return .5
