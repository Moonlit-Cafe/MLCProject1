## The UI item for actual holding ItemNodes
class_name ShopSlot extends InventorySlot

#region Declarations
#endregion

#region Events
func attempt_purchase() -> void:
	if held_item == null:
		return
		
	# TODO Tyler Checks, after basic version is ready
		# If non mat, is there an open slot of this type?
		# Space in inventory?
		# is there enough money?
	PlayerManager.accept_item(held_item.item)
	PlayerManager.money -= held_item.item.value
	held_item = null
	
	pass
#endregion

#region Signal Callbacks
#endregion
