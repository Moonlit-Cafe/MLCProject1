class_name FlatStatChange extends Change

#region Declarations
@export var stat : Genum.StatType
@export var value : float
#endregion

#region Events
func apply(target) -> void:
	var old = target.stats[stat]
	
	target.stats[stat] += value
	Global.logs.post_message(null, \
	"%s given flat stat change of %s to %s. Originally %s, now %s" \
	% [target, value, stat, old, target.stats[stat]])
#endregion
