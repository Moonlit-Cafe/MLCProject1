## Handles all the weapon specific data.
class_name EquippableNode extends ItemNode

#region Events
func update_display() -> void:
	super()
	
	if count_label:
		count_label.text = Genum.EquipLocation.keys()[item.equip_loc].substr(0,4)
		count_label.visible = true
		
		# TODO TYLER add bomba item set effect to data
		return

func unequip() -> void:
	pass
		
#endregion
