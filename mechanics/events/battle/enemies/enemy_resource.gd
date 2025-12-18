class_name EnemyCharacter extends Resource

#region Declarations
enum AIType {
	NULL,
	MELEE,
	ARCHER,
	CASTER,
	HEALER,
	SUPPORTER
}

enum EnemyState {
	ACTIVE,
	BACKUP,
	SUPPORT
}

@export var o_name : StringName ## The name of the enemy type
@export var haste : int = 10 ## How fast the enemy is
## The base stats of the enemy
@export var stats : Dictionary[StringName, int] = {
	&"hp" : 10,
	&"p_def": 0,
	&"m_def": 0,
	&"p_atk": 1,
	&"m_atk": 0,
}
## The rate at which the enemy's stats scale with difficulty
@export var stats_scaling : Dictionary[StringName, float] = {
	&"hp" : 1.0,
	&"p_def": 1.0,
	&"m_def": 1.0,
	&"p_atk": 1.0,
	&"m_atk": 1.0,
}
# PLANNED: Might wanna make a couple Consideration Schemes and that could be the AI types
@export var ai_type : AIType = AIType.NULL ## The type of AI the enemy uses
@export var current_state : EnemyState = EnemyState.ACTIVE ## The type of unit this enemy is
# TODO: Later, need to standardize the animation scheme for the enemies
@export var frames : SpriteFrames ## The visual animations of the enemy
#endregion

#region Events
## Used when the enemy is attacking.
func attack() -> int:
	# TODO: Will later use consideration system to potentially separate the attack types.
	var phys_attack := int(stats.get(&"p_atk") * CombatManager.difficulty_modifier * stats_scaling.get(&"p_atk"))
	var mag_attack := int(stats.get(&"m_atk") * CombatManager.difficulty_modifier * stats_scaling.get(&"m_atk"))
	return phys_attack + mag_attack

## Used when the enemy is defending against an attack.
func defend(ac: Action) -> int:
	var attack_value := int(ac.value)
	# TODO: Differentiate between magic attacks and physical attacks.
	var phys_defense := int(stats.get(&"p_def") * CombatManager.difficulty_modifier * stats_scaling.get(&"p_def"))
	var mag_defense := int(stats.get(&"m_def") * CombatManager.difficulty_modifier * stats_scaling.get(&"m_def"))
	return attack_value - (phys_defense + mag_defense)
#endregion
