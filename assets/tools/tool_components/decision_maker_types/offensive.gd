class_name Offensive extends DecisionMaker

@export var cons : Array[Decider]

## TODO: always play aggressive, spending mana freely for spells / attacks, disregard hp considerations of self
func score(p_dict:Dictionary) -> float :
	return .5
