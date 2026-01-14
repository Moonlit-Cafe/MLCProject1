class_name Considerations extends Node

#region Declarations
var enemy : TileEnemy
var targets : Dictionary = {}
#endregion

#region Events
func _ready() -> void:
	GameGlobalEvents.act.connect(handle_actions)
	GameGlobalEvents.thinking.connect(print_thought)
	
func print_thought(data:String) -> void :
	print(data)

func handle_actions() -> void :
	pass

func decide(decision_target: TileEntity, decision_list : Array[DeciderHolder]) -> DeciderHolder:
	print_thought("Clearing my head...")
	var _best_decision : DeciderHolder = null
	## handle in our sub decider logic types
	print_thought("Now thinking about my turn...")
	for decider in decision_list:
		var can_use := false
		var action : Action = CombatManager.skill_manager.get_action(decider.action)
		if decision_target.get_stat(Genum.StatType.AETHER).x - action.ac_cost.cost_amount >= 0 :
			can_use = true
			print_thought("Can us %s..." % action.ac_name)
		else :
			print_thought("Not enough mp for %s..." % action.ac_name)
			
		if not _best_decision:
			_best_decision = decider
		elif decider.score(decision_target) > _best_decision.score(decision_target) and can_use:
			_best_decision = decider
			print_thought("New best action saved! Action: %s" % action.ac_name)
	
	var best_action = CombatManager.skill_manager.get_action(_best_decision.action)
	print_thought("Sending my decision... Action: %s" % best_action.ac_name)
	return _best_decision
#endregion
