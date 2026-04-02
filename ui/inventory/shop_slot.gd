## The UI item for actual holding ItemNodes
class_name ShopSlot extends InventorySlot

#region Declarations
#endregion

#region Events
# TODO Tyler Make shop interact with buttons right
	# take item from s stock
	# take p money
	# TODO Tyler Add checks for money later
func attempt_purchase() -> void:
	if held_item == null:
		return
		
	PlayerManager.accept_item(held_item.item)
	PlayerManager.money -= held_item.item.value
	held_item.queue_free()
	held_item = null
	
	pass
#endregion

#region Signal Callbacks
#endregion
