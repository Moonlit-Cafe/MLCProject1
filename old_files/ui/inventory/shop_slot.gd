## The UI item for actual holding ItemNodes
class_name ShopSlot extends InventorySlot

#region Declarations
#endregion

#region Events
	
func attempt_purchase() -> void:
	if held_item == null:
		return
		
	if PlayerManager.money < held_item.item.value:
		# TODO Add a visual indicator to Player being unable to buy thigns
		# TODO add a label beneath buttons to indicate values held in slots
		# Remove the warning after that, rn its just a placeholder until we have visuals
		push_warning("Player has attempted to buy %s worth %s. They only have %s." % 
		[held_item.item, held_item.item.value, PlayerManager.money])
		return
	
		
	PlayerManager.accept_item(held_item.item)
	PlayerManager.money -= held_item.item.value
	held_item.queue_free()
	held_item = null
	
	pass
#endregion

#region Signal Callbacks
#endregion
