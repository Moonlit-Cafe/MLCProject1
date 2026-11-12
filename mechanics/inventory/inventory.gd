class_name Inventory extends Resource

#region Declarations
signal inventory_changed

@export var slots : Array[InventorySlot] = []
@export var max_slots : int = 20 :
	set(value):
		max_slots = maxi(value, 0)
		_sync_slots()
#endregion

#region Events
func _init() -> void:
	_sync_slots()

func _sync_slots() -> void:
	while slots.size() < max_slots:
		slots.append(InventorySlot.new())
	while slots.size() > max_slots and not slots.is_empty() and slots.back().is_empty():
		slots.pop_back()
#endregion

func add_item(new_item: BasicItem, amount: int = 1) -> int:
	if new_item == null or amount <= 0:
		return amount
	var remaining := amount
	
	for slot in slots:
		if remaining <= 0:
			break
		
		if slot.can_stack(new_item):
			var space := maxi(new_item.stack_size - slot.quantity, 0)
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

func check_craftable() -> Array[Recipe]:
	var recipe_list : Array[Recipe] = []
	for slot in slots:
		if slot.is_empty():
			continue
		for recipe_entry in slot.item.recipes:
			var recipe := recipe_entry as Recipe
			if recipe == null or recipe_list.has(recipe):
				continue
			recipe_list.append(recipe)
	
	var craftable : Array[Recipe] = []
	for recipe in recipe_list:
		if recipe.is_craftable(self):
			craftable.append(recipe)
	return craftable

func get_all_with_tag(tag: BasicItem.Tags) -> Array[InventorySlot]:
	var slots_with_tag : Array[InventorySlot] = []
	for slot : InventorySlot in slots:
		if slot.is_empty():
			continue
		
		if slot.item.tags.has(tag):
			slots_with_tag.append(slot)
	
	return slots_with_tag

func remove_item(target_item: BasicItem, amount: int = 1) -> bool:
	if target_item == null:
		return false
	var remaining := amount
	
	for slot in slots:
		if remaining <= 0:
			break
		if not slot.is_empty() and slot.item.id == target_item.id:
			var to_remove := mini(remaining, slot.quantity)
			slot.quantity -= to_remove
			remaining -= to_remove
			if slot.quantity <= 0:
				slot.item = null
				slot.quantity = 0
	
	inventory_changed.emit()
	return remaining <= 0
#endregion
