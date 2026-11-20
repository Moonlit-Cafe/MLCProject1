##Buffs are TempStatChanges that are temporary
class_name TempStatChange extends FlatStatChange

#region Declarations
@export var duration : int
# TODO find a way to "attach" these effects to the target.
# This probably means entities should have a function to tick down effects when doing something that has a time cost
#endregion

#region Events
func apply(target) -> void:
	pass
#endregion
