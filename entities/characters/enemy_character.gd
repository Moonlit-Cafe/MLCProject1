## Data pertaining to the Enemy Character Type
class_name EnemyCharacter extends BaseCharacter

#region Declarations
enum EnemyType {
	NULL
}

@export var actions : Array[AIAction] = []
@export var tags : Array[EnemyType] = [EnemyType.NULL]
#endregion
