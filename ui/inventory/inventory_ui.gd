extends Control

#region Declarations
@export var inventory : Inventory
@export var slot_scene : PackedScene

@onready var grid : GridContainer = $GridContainer
#endregion

#region Events
func _ready() -> void:
	inventory.inventory_changed.connect(_refresh_inventory)
	_refresh_inventory()

func _refresh_inventory() -> void:
	for child in grid.get_children():
		child.queue_free()
	
	for slot in inventory.slots:
		var ui_slot : InventoryUISlot = slot_scene.instantiate()
		ui_slot.inventory = inventory
		ui_slot.set_slot_data(slot)
		grid.add_child(ui_slot)
#endregion
