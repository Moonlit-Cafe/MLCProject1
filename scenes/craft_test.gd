extends Control

# Temporary scene to ensure that CraftManager works, will exist until a general test scene for the game is made
# during each major phase of development.

@export var initial_items : Array[Item]
@export var inv_size := Vector2i(6, 2)
var inventory : Array[ItemNode]

@export var craft_area : VBoxContainer
@export var inv_area : GridContainer

func _ready() -> void:
	CraftManager.craft_request.connect(_on_craft_requested)
	
	if inv_area:
		inv_area.columns = inv_size.x
	
	for item in initial_items:
		var node := ItemNode.new()
		node.item = item
		node.count = 99
		node.inv_pos = Vector2i(inventory.size(), 0)
		inventory.append(node)
	
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
	inventory = CraftManager.craft(button_name, inv_size, inventory)
	refresh_inventory()
	CraftManager.request_craft_list(inventory)

func populate_inventory() -> void:
	for node in inventory:
		var item_hbox := VBoxContainer.new()
		var item_count_label := Label.new()
		node.text = node.item.i_name
		item_count_label.text = "%s" % node.count
		inv_area.add_child(item_hbox)
		item_hbox.add_child(node)
		item_hbox.add_child(item_count_label)

func refresh_inventory() -> void:
	for node in inventory:
		if not node.item:
			node.get_parent().queue_free()
			inventory.erase(node)
		if node.get_parent():
			for child in node.get_parent().get_children():
				if child is Label:
					child.text = "%s" % node.count
		else:		
			var item_vbox := VBoxContainer.new()
			var item_count_label := Label.new()
			node.text = node.item.i_name
			item_count_label.text = "%s" % node.count
			inv_area.add_child(item_vbox)
			item_vbox.add_child(node)
			item_vbox.add_child(item_count_label)
