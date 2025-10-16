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
@export var ai_type : AIType = AIType.NULL
@export var current_state : EnemyState = EnemyState.ACTIVE
@export var frames : SpriteFrames
#endregion

#region Actions
func attack() -> int:
	return int(stats.get(&"p_atk") + stats.get(&"m_atk"))

func defend(ac: Action) -> int:
	return int(ac.value)
#endregion
