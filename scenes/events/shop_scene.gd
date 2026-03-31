extends BaseEventScene

@export var shop_slots : HBoxContainer

# FIXME: There's regual inventory movement mechanics within the shop, we'll section it off later.
# TODO Tyler Add money to player
	# make enemies drop money on die
	# make enemies drop items on die (sometimes)
# TODO Tyler Make shop interact with buttons right
	# Add item to p inventory
	# take item from s stock
	# take p money
	
func _ready() -> void:
	_generate_shop()

func _generate_shop() -> void:
	for slot in shop_slots.get_children():
		if slot is not InventorySlot:
			break
		
		var item := CraftManager.get_valued_items(0, 10, 1)[0]
		slot.generate_item(item.i_name)

func _on_pressed() -> void:
	SceneManager.load_next_scene()
