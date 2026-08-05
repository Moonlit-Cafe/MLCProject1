## Data pertaining to the Enemy Character Type
class_name EnemyCharacter extends BaseCharacter

#region Declarations
enum EnemyType {
	NULL
}

@export var tags : Array[EnemyType] = [EnemyType.NULL]
#endregion
