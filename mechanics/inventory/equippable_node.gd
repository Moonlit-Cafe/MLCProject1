## Handles all the weapon specific data.
class_name EquippableNode extends ItemNode


#region Events
func update_display() -> void:
	super()
	
	if count_label:
		count_label.text = Genum.EquipLocation.keys()[item.equip_loc].substr(0,4)
		# TODO TYLER Check player equipped for set
		# Get player
		# check for equip slots
		# if slot has an item
		# if item is equippable
		# if equip is same set as this
		count_label.visible = true
		
		# TODO TYLER implement player equip slots
		
		# TODO TYLER add bomba item set effect to data

		return
		
func _on_equip() -> void:
	pass
		
#endregion
