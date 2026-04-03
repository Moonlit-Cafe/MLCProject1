## The UI item for actual holding ItemNodes
class_name ShopSlot extends InventorySlot

#region Declarations
#endregion

#region Events
	
func attempt_purchase() -> void:
	if held_item == null:
		return
	if PlayerManager.money < held_item.item.value:
		push_warning("Player has attempted to buy %s worth %s. They only have %s." 
				% held_item.item, held_item.item.value, PlayerManager.money)
		return
	
		
	PlayerManager.accept_item(held_item.item)
	PlayerManager.money -= held_item.item.value
	held_item.queue_free()
	held_item = null
	
	pass
#endregion

#region Signal Callbacks
#endregion
