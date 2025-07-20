extends Control

@export var preload_resources : Array[Item] = []
@onready var inventory : Array[Array] = [
	[preload_resources.get(0), 99],
	[preload_resources.get(1), 99],
	[preload_resources.get(2), 99],
	[preload_resources.get(3), 99],
	[preload_resources.get(4), 99]
]

@export var craft_area : VBoxContainer
@export var inv_area : VBoxContainer

func _ready() -> void:
	CraftManager.craft_request.connect(_on_craft_requested)
	
	populate_inventory()
	
	CraftManager.request_craft_list(inventory)
	

func _on_craft_requested() -> void:
	for child in craft_area.get_children():
		craft_area.remove_child(child)
		child.queue_free()
	
	for item in CraftManager.available_to_craft:
		var item_button := CraftButton.new()
		item_button.text = item.i_name
		craft_area.add_child(item_button)
		
		item_button.craft_requested.connect(_on_craft_button_pressed)

func _on_craft_button_pressed(button_name: StringName) -> void:
	inventory = CraftManager.craft(button_name, inventory)
	populate_inventory()
	CraftManager.request_craft_list(inventory)

func populate_inventory() -> void:
	for child in inv_area.get_children():
		inv_area.remove_child(child)
		child.queue_free()
	
	for item in inventory:
		var item_hbox := HBoxContainer.new()
		var item_label := Label.new()
		var item_count_label := Label.new()
		item_label.text = item.get(0).i_name
		item_count_label.text = "%s" % item.get(1)
		inv_area.add_child(item_hbox)
		item_hbox.add_child(item_label)
		item_hbox.add_child(item_count_label)
