class_name FlatStatChange extends Change

#region Declarations
@export var stat : Genum.StatType
@export var value : float
#endregion

#region Events
func apply(target:TileEntity) -> void:
	var old = target.stats[stat]
	
	target.stats[stat] += value
	Global.logs.post_message(target, \
	"%s given flat stat change of %s to %s. Originally %s, now %s" \
	# TODO str(stat) reads as the numerical index, not as the actual name of the stat
	% [target, value, str(stat), old, target.stats[stat]])
#endregion
