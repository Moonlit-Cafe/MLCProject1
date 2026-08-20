class_name InventorySlot extends Resource

#region Declarations
var item : BasicItem = null
var quantity : int = 0
#endregion

#region Events
func can_stack(new_item: BasicItem) -> bool:
	return (item == new_item) and quantity < item.stack_size

func is_empty() -> bool:
	return item == null
#endregion
