extends BaseEventScene

@export var shop_slots : HBoxContainer

# FIXME: There's regual inventory movement mechanics within the shop, we'll section it off later.
func _ready() -> void:
	_generate_shop()

func _generate_shop() -> void:
	var compendium_size := CraftManager.get_compendium_size()
	for slot in shop_slots.get_children():
		if slot is not InventorySlot:
			break
		
		var item := CraftManager.get_random_item()
		slot.generate_item(item.i_name)

func _on_pressed() -> void:
	SceneManager.load_next_scene()
