class_name DecisionMaker extends Node

## TODO: Foundation for enemy logic presets

var _best_score : float = 0.0
var _best_action : Ability


func _ready() -> void:
	set_up_test_actions()
	
func set_up_test_actions() :
	## Set up our test actions
	pass

func decide(actions:Array[Ability]) -> void :
	## handle in our sub decider logic types
	for a in actions :
		var score = 0.0
		for c in a.considerations :
			score += c.score
			
		score = (score / a.considerations.size())
		if score > _best_score :
			_best_score = score
			_best_action = a
			print("%s is now the best action, with score: %s." % a.ac_name,a.ac_score)
		
	pass
