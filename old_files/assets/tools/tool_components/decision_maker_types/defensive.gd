class_name Defensive extends DecisionMaker

@export var cons : Array[Decider]

## TODO: always play defensive, use mana for healing / block / armor up / etc
func score(p_dict:Dictionary) -> float :
	return .5
