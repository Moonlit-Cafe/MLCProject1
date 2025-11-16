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

@export var o_name : StringName
@export var haste : int = 10
@export var stats : Dictionary[StringName, int] = {
	&"hp" : 10,
	&"p_def": 0,
	&"m_def": 0,
	&"p_atk": 1,
	&"m_atk": 0,
}
@export var stats_scaling : Dictionary[StringName, float] = {
	&"hp" : 1.0,
	&"p_def": 1.0,
	&"m_def": 1.0,
	&"p_atk": 1.0,
	&"m_atk": 1.0,
}
@export var ai_type : AIType = AIType.NULL
@export var current_state : EnemyState = EnemyState.ACTIVE
@export var frames : SpriteFrames
#endregion

#region Actions
func attack() -> int:
	var phys_attack := int(stats.get(&"p_atk") * CombatManager.difficulty_modifier * stats_scaling.get(&"p_atk"))
	var mag_attack := int(stats.get(&"m_atk") * CombatManager.difficulty_modifier * stats_scaling.get(&"m_atk"))
	return phys_attack + mag_attack

func defend(ac: Action) -> int:
	var attack_value := int(ac.value)
	# TODO: Differentiate between magic attacks and physical attacks.
	var phys_defense := int(stats.get(&"p_def") * CombatManager.difficulty_modifier * stats_scaling.get(&"p_def"))
	var mag_defense := int(stats.get(&"m_def") * CombatManager.difficulty_modifier * stats_scaling.get(&"m_def"))
	return attack_value - (phys_defense + mag_defense)
#endregion
