class_name InventoryUISlot extends PanelContainer

#region Declarations
@onready var icon : TextureRect = $Icon
@onready var quantity_label : Label = $QuantityLabel

var inventory : Inventory = null
var slot_data : InventorySlot = null
#endregion

#region Events
func _get_drag_data(_pos: Vector2) -> Variant:
	if slot_data.is_empty():
		return null
	
	var preview := TextureRect.new()
	preview.texture = slot_data.item.icon
	preview.size = Vector2(64, 64)
	set_drag_preview(preview)
	
	return {"slot": slot_data, "source": self}

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("slot")

func _drop_data(_pos: Vector2, data: Variant) -> void:
	var source_slot : InventorySlot = data.slot
	
	var temp_item := slot_data.item
	var temp_qty := slot_data.quantity
	slot_data.item = source_slot.item
	slot_data.quantity = source_slot.quantity
	source_slot.item = temp_item
	source_slot.quantity = temp_qty
	inventory.inventory_changed.emit()

func set_slot_data(slot: InventorySlot) -> void:
	if slot.is_empty():
		icon.texture = null
		quantity_label.text = ""
	else:
		icon.texture = slot.item.icon
		quantity_label.text = str(slot.quantity) if slot.quantity > 1 else ""
#endregion
