class_name CombatEvents extends GlobalEvents

var list_of_triggers : Array[EffectChange]

func incoming_trigger(new_trigger:EffectChange, inc_target : TileEntity) -> void:
	var inc = new_trigger.new()
	inc.target = inc_target
	list_of_triggers.append(inc)
	
	
func check_triggers(time_chunk:TimeCost) -> void:
	var index = 0 
	for trigger in list_of_triggers:
		if time_chunk.type == trigger.duration.type:
			trigger.duration.value -= time_chunk.value
			for change in trigger.total_changes:
				change.apply(trigger.target)
				
			if trigger.duration.value <= 0:
				list_of_triggers.remove_at(index)
				trigger.queue_free()
				index -= 1
			index += 1
