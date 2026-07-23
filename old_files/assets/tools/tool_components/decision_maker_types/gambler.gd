class_name Gambler extends DecisionMaker

@export var cons : Array[Decider]

## TODO: always select a random action
func score(p_dict:Dictionary) -> float :
	return .5
