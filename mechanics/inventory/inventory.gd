class_name Inventory extends Resource

#region Declarations
signal inventory_changed

@export var slots : Array[InventorySlot] = []
@export var max_slots : int = 20
#endregion

#region Events
func _init() -> void:
	for i in range(max_slots):
		slots.append(InventorySlot.new())

func add_item(new_item: ItemResource, amount: int = 1) -> int:
	var remaining := amount
	
	for slot in slots:
		if remaining <= 0:
			break
		
		if slot.can_stack(new_item):
			var space := new_item.stack_size - slot.quantity
			var to_add := mini(remaining, space)
			slot.quantity += to_add
			remaining -= to_add
	
	for slot in slots:
		if remaining <= 0:
			break
		if slot.is_empty():
			slot.item = new_item
			var to_add := mini(remaining, new_item.stack_size)
			slot.quantity = to_add
			remaining -= to_add
	
	inventory_changed.emit()
	return remaining

func remove_item(target_item: ItemResource, amount: int = 1) -> bool:
	var remaining := amount
	
	for slot in slots:
		if remaining <= 0:
			break
		if slot.item == target_item:
			var to_remove := mini(remaining, slot.quantity)
			slot.quantity -= to_remove
			remaining -= to_remove
			if slot.quantity <= 0:
				slot.item = null
				slot.quantity = 0
	
	inventory_changed.emit()
	return remaining <= 0
#endregion
