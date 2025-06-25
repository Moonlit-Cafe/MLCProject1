extends Button

@export var craft_slots : Array[ItemSlot]
@export var result_slot : ItemSlot

func _on_pressed() -> void:
	var items : Array[Item]
	for slot in craft_slots:
		var item = slot.request_item_info()
		if item:
			items.append(item)
	
	var result = CraftManager.request_craft(items)
	if result:
		for slot in craft_slots:
			slot.remove_item()
		result_slot.add_item(result.item_name)
	
