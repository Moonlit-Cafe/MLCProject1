##Class for Buff/Debuff effects
class_name EffectChange extends Change

#region Declarations
@export var duration : TimeCost
# total changes : Array[flat stat changes]
#endregion


#region Events
## Applys a buff to the target
func apply(target) -> void:
	pass
# whenever this is applied
	# entity triggers this when ending turn
# do some math
# apply stat change
# reduce duration by 1
# reduce total changes by amount
# if duration <= 0 remove self
#endregion
