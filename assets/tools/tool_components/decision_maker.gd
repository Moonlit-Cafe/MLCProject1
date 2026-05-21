class_name DecisionMaker extends Node

## TODO: Foundation for enemy logic presets

@export var ability_node : VBoxContainer

var my_abilities : Array[Ability]

var self_hp : float = 0
var self_mp : float = 0

var _best_score : float = 0.0
var _best_action : Ability

func set_resources(hp:float,mp:float) -> void:
	self_hp = hp
	self_mp = mp
	
func set_actions(abilities : Array[String] = ["light","heavy","magic"]) :
	my_abilities.clear()
	think_out_loud("Thinking about my abilities...")
	for a in abilities :
		for c in ability_node.get_children() :
			if a == c.ac_name:
				think_out_loud("Adding Ability: %s" % c.ac_name)
				my_abilities.append(c)
	think_out_loud("Done thinking about abilities...")

func decide(target:UnitBox, origin_unit:UnitBox) -> Array[Variant] :
	think_out_loud("Clearing my head...")
	_best_action = Ability.new()
	_best_score = 0
	## handle in our sub decider logic types
	think_out_loud("Now thinking about my turn...")
	for a in my_abilities :
		var score = 0.0
		for c in a.deciders :
			if self_mp - a.ac_cost >= 0 :
				score += c.score(target, origin_unit)
				think_out_loud("Increasing score...")
			else :
				think_out_loud("Not enough mp for %s..." % a.ac_name)
			
		score = (score / a.deciders.size())
		think_out_loud("Action score average for %s is %s!" % [a.ac_name,score])
		if score > _best_score :
			_best_score = score
			_best_action = a
			think_out_loud("New best action saved! Action: %s, Avg Score: %s" % [_best_action.ac_name,_best_score])
	
	think_out_loud("Sending my decision... Action: %s, Score: %s" % [_best_action.ac_name,_best_score])
	GameGlobalEvents.act.emit(_best_action.ac_name, target.unit_name)
	return [_best_action,_best_score]
	
func think_out_loud(data:String) -> void :
	GameGlobalEvents.thinking.emit(data)
