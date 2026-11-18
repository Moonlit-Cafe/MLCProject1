##Class for Buff/Debuff effects
class_name EffectChange extends Change

#region Declarations
@export var duration : TimeCost
var total_changes : Array[FlatStatChange]
var target : TileEntity
#endregion


#region Events
## Applies an effect to a target. The triggers for the effects are listened for in CombatEvents
func apply(target:TileEntity) -> void:
	Global.combat.incoming_trigger(self, target)
#endregion
