class_name EnemyCharacter extends CharacterResource

#region Declarations
enum EnemyState {
	ACTIVE,
	BACKUP,
	SUPPORT
}

@export var haste : int = 10 ## How fast the enemy is
## The base stats of the enemy
@export var enemy_stats : Dictionary[Genum.StatType, float] = {
	Genum.StatType.STAMINA: 0.,
	Genum.StatType.AETHER: 0.,
	Genum.StatType.BARRIER: 0.,
	Genum.StatType.ATTACK: 1.,
	Genum.StatType.MAGIC: 0.,
}
## The rate at which the enemy's stats scale with difficulty
@export var stats_scaling : Dictionary[Genum.StatType, float] = {
	Genum.StatType.HEALTH: 1.0,
	Genum.StatType.STAMINA: 1.0,
	Genum.StatType.BARRIER: 1.0,
	Genum.StatType.ATTACK: 1.0,
	Genum.StatType.MAGIC: 1.0,
}
# PLANNED: Might wanna make a couple Consideration Schemes and that could be the AI types
@export var current_state : EnemyState = EnemyState.ACTIVE ## The type of unit this enemy is
# TODO: Later, need to standardize the animation scheme for the enemies
#endregion

#region Events
func init() -> void:
	super()
	_build_stats(enemy_stats)

## Used when the enemy is attacking.
func attack(decision: Decider, c_stats: Dictionary[Genum.StatType, float]) -> int:
	var action : CombatAction = ResourceManager.action_compendium.get(decision.action)
	
	# TODO: Will later use consideration system to potentially separate the attack types.
	var mod : float = CombatManager.difficulty_modifier
	var attack_stat : Genum.StatType
	var cost_stat : Genum.StatType
	match(action.ac_cost.CostType):
		AbilityCostPacket.CostType.MANA:
			attack_stat = Genum.StatType.MAGIC
			cost_stat = Genum.StatType.AETHER
		AbilityCostPacket.CostType.STAMINA:
			attack_stat = Genum.StatType.ATTACK
			cost_stat = Genum.StatType.STAMINA
	
	if action.ac_cost.cost_amount >= c_stats.get(cost_stat):
		return action.value + c_stats.get(attack_stat) + mod
	else:
		return 0

## Used when the enemy is defending against an attack.
func defend(ac: CombatAction) -> int:
	var attack_value := int(ac.value)
	# TODO: Differentiate between magic attacks and physical attacks.
	var mod : float = CombatManager.difficulty_modifier
	var attack_stat := Genum.StatType.ATTACK
	var magic_stat := Genum.StatType.MAGIC
	
	var phys_defense := int(stats.get(attack_stat) * mod * stats_scaling.get(attack_stat))
	var mag_defense := int(stats.get(magic_stat) * mod * stats_scaling.get(magic_stat))
	return attack_value - (phys_defense + mag_defense)
#endregion
