class_name EnemyBox extends UnitBox

@export var actions : Array[String]
@export var brain : DecisionMaker

var choices_dict = {}
var best_act : Ability
var best_score : float = 0.0

func _ready() -> void:
	super._ready()
	brain.set_actions(actions)
	brain.set_resources(health,mana)
	

func process_turn(player:UnitBox) -> void :
	var temp = brain.decide(player, self) ## Returns Variant Array (Ability, Score)
	best_act = temp[0]
	best_score = temp[1]
	
	mana -= temp[0].ac_cost
	brain.self_mp = mana
	
	do_action(best_act)
	
	## Clear after we've acted.
	best_score = 0.0
	best_act = Ability.new()
	
func do_action(_act:Ability) -> void :
	GameGlobalEvents.act.emit(_act.ac_name,"player")
	
## Multi Target Testing (later)
#func process_turn(possible_targets:Array[UnitBox]) -> void :
	#for target in possible_targets :
		#var temp = brain.decide(target) as Array[Variant]
		#choices_dict[temp[0].ac_name] = [temp[0].ac_name, temp[0],temp[1]]
	#
	#var target = choose_target(choices_dict) as UnitBox
#
#
#func choose_target(choices:Dictionary) -> UnitBox :
	#
