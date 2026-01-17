class_name EnemyBox extends UnitBox

@export var actions : Array[String]

var best_act : Ability
var best_score : float = 0.0

func _ready() -> void:
	super._ready()
	

func process_turn(player:UnitBox) -> void :
	var decision_list = character.deciders.deciders.get(DeciderHolder.TargetType.PLAYER)
	var player_ref = get_tree().get_first_node_in_group(&"player")
	var temp = CombatManager.consideration_manager.decide(player_ref, decision_list) ## Returns Variant Array (Ability, Score)
	best_act = temp[0]
	best_score = temp[1]
	
	aether -= temp[0].ac_cost
	brain.self_mp = aether
	
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
