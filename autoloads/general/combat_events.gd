class_name CombatEvents extends GlobalEvents

var list_of_triggers : Array[EffectChange]

func incoming_trigger(new_trigger:EffectChange, inc_target : TileEntity) -> void:
	var inc = new_trigger.new()
	inc.target = inc_target
	list_of_triggers.append(inc)
	
	
func check_triggers(time_chunk:TimeCost) -> void:
	for trigger in list_of_triggers:
		if time_chunk.type == trigger.duration.type:
			trigger.duration.value -= time_chunk.value
			for change in trigger.total_changes:
				change.apply(trigger.target)

# whenever this is applied
	# entity triggers this when ending turn
# do some math
# apply stat change
# reduce duration by 1 
# reduce total changes by amount
# if duration <= 0 remove self
