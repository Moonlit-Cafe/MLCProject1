## ActionSet is used to clump all available actions and 'tag' them based on an using entities
## condition. For example, a phase 2 set of attacks for a boss, or if an entity is in a "flee" state
## it could access more unique abilities.
class_name ActionSet extends Resource

#region Declarations
enum Conditions {
	DEFAULT
}

@export var sets : Dictionary[Conditions, ActionArray]
#endregion

#region Events
func check_condition(_entity: TileEntity) -> ActionArray:
	return sets.get(Conditions.DEFAULT)

func size() -> int:
	return 0
#endregion
