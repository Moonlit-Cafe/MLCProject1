## The Debug terminal for most if not all debug handling.
## Used by adding commands as methods to this script.
extends CanvasLayer

#region Variables
@export var text_box : TextEdit
@export var text_line : LineEdit
@export var tier_select: OptionButton
@export var type_select: OptionButton
@export var amount_line: LineEdit
@export var add_button: Button
@export var materials_display: TextEdit

var text : String = "Debug Terminal"
#endregion

#region Built-Ins
func _ready() -> void:
	text_box.set_line(0, text)
	text_box.set_line(1, "Type \"help\" to list commands")
	_populate_debug_add_options()
	_refresh_materials_display()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"debug"):
		if visible:
			hide()
		else:
			show()
#endregion

#region Helpers
func _add_line(new_text: String) -> void:
	text += "\n%s" % [new_text]

func _populate_debug_add_options() -> void:
	if tier_select:
		tier_select.clear()
		# Add tiers with enum IDs
		tier_select.add_item("Motal", Genum.Rarity.MOTAL)
		tier_select.add_item("Pebbled", Genum.Rarity.PEBBLED)
		tier_select.add_item("Cometary", Genum.Rarity.COMETARY)
		tier_select.add_item("Planetary", Genum.Rarity.PLANETARY)
		tier_select.add_item("Stellar", Genum.Rarity.STELLAR)
		tier_select.add_item("Nebulous", Genum.Rarity.NEBULOUS)
		tier_select.add_item("Cosmic", Genum.Rarity.COSMIC)
		tier_select.select(0)
	
	if type_select:
		type_select.clear()
		# Add material types with enum IDs
		type_select.add_item("Cloth", Genum.MaterialType.CLOTH)
		type_select.add_item("Dust", Genum.MaterialType.DUST)
		type_select.add_item("Leather", Genum.MaterialType.LEATHER)
		type_select.add_item("Metal", Genum.MaterialType.METAL)
		type_select.add_item("Wood", Genum.MaterialType.WOOD)
		type_select.select(0)
	
	if amount_line and amount_line.text == "":
		amount_line.text = "1"
#endregion

#region Signal Callbacks
func _on_text_submit(new_text: String) -> void:
	text_line.text = ""
	if new_text[0] == "/":
		var command_text := new_text.split("/")[1]
		var command := command_text.split(" ")
		var command_name := command[0]
		var args : Array[String] = []
		if command.size() > 1:
			args = command.slice(1)
		
		if self.has_method(command_name):
			var callable = Callable(self, command_name)
			callable.call(args)
		else:
			_add_line("There is no command by the name %s" % command_name)
	else:
		_add_line("That was not a command, please use /")
	
	text_box.text = text
	text_box.scroll_vertical = text_box.get_line_count() - 1
#endregion

#region Commands
# Basic idea is to add a method and then it essentially becomes a command because of how _on_text_submit works

## TODO: Fix the  "help" command

## When called it will either provide a list of available commands or give information about a particular command
func help(args: Array[String]) -> void:
	if args.size() == 0:
		var command_list : Array[String] = [
			"help"
		]
		
		_add_line("List of Available Commands:")
		for command in command_list:
			_add_line("%s" % command)

func clear(_args: Array[String]) -> void:
	text = "Debug Terminal"
#endregion

#region UI Callbacks
func _on_add_pressed() -> void:
	var selected_tier: int = tier_select.get_selected_id() if tier_select else 0
	var selected_type: int = type_select.get_selected_id() if type_select else Genum.MaterialType.CLOTH
	var amount_text: String = amount_line.text if amount_line else "1"
	var amount_to_add: int = max(1, int(amount_text))

	var found_item: Item = _find_item_by_tier_and_type(selected_tier, selected_type)
	if not found_item:
		_add_line("No item found for type %s at tier %s" % [str(selected_type), str(selected_tier)])
		text_box.text = text
		text_box.scroll_vertical = text_box.get_line_count() - 1
		return
	
	var remaining: int = amount_to_add
	remaining = _try_stack_into_existing(found_item, remaining)
	if remaining > 0:
		remaining = _spawn_into_empty_slots(found_item, remaining)
	
	var added_count = amount_to_add - remaining
	if added_count > 0:
		_add_line("Added %d x %s" % [added_count, found_item.get_display_name()])
	if remaining > 0:
		_add_line("Inventory full or max stacks reached. Could not add %d items." % remaining)
	
	text_box.text = text
	text_box.scroll_vertical = text_box.get_line_count() - 1
	
	# Refresh materials display after adding items
	_refresh_materials_display()

func _find_item_by_tier_and_type(tier: int, material_type: int) -> Item:
	# Prefer exact tier match; fallback to any item of that material type
	if CraftManager and CraftManager.item_compendium:
		var fallback: Item = null
		for item in CraftManager.item_compendium.item_reference:
			if item is MaterialItem:
				var mat_item := item as MaterialItem
				if mat_item.material_type == material_type:
					if mat_item.tier == tier:
						return item
					if fallback == null:
						fallback = item
		return fallback
	return null

func _try_stack_into_existing(item: Item, amount: int) -> int:
	var remaining = amount
	for node in get_tree().get_nodes_in_group(&"inv_slots"):
		if remaining <= 0:
			break
		if not node is InventorySlot:
			continue
		var slot: InventorySlot = node as InventorySlot
		if slot.held_item and slot.held_item.item and slot.held_item.item.id == item.id:
			remaining = slot.held_item.add_to_stack(remaining)
	return remaining

func _spawn_into_empty_slots(item: Item, amount: int) -> int:
	var remaining = amount
	for node in get_tree().get_nodes_in_group(&"inv_slots"):
		if remaining <= 0:
			break
		if not node is InventorySlot:
			continue
		var slot: InventorySlot = node as InventorySlot
		if slot.is_empty():
			var to_place = min(remaining, item.max_stack_size)
			var item_scene: PackedScene = slot.item_node
			if not item_scene:
				# Fallback to loading scene directly
				item_scene = load("res://mechanics/inventory/item_node.tscn")
			var item_node: ItemNode = item_scene.instantiate()
			item_node.setup_item(item, to_place)
			slot.add_child(item_node)
			remaining -= to_place
	return remaining

func _refresh_materials_display() -> void:
	if not materials_display:
		return
	
	var materials_text := ""
	var material_counts := {}
	
	# Collect all materials from inventory slots
	for node in get_tree().get_nodes_in_group(&"inv_slots"):
		if not node is InventorySlot:
			continue
		var slot: InventorySlot = node as InventorySlot
		if slot.held_item and slot.held_item.item and slot.held_item.item is MaterialItem:
			var mat_item := slot.held_item.item as MaterialItem
			var key := "%s_Tier%d" % [GenumHelper.MATERIAL_TYPE.get(mat_item.material_type), mat_item.tier]
			if not material_counts.has(key):
				material_counts[key] = 0
			material_counts[key] += slot.held_item.count
	
	# Format the display
	if material_counts.is_empty():
		materials_text = "No materials found in inventory"
	else:
		var tier_names := ["Motal", "Pebbled", "Cometary", "Planetary", "Stellar", "Nebulous", "Cosmic"]
		var type_names := ["Cloth", "Dust", "Leather", "Metal", "Wood"]
		
		for key in material_counts.keys():
			var parts: Array[String] = key.split("_")
			if parts.size() >= 2:
				var material_type: String = parts[0]
				var tier_str: String = parts[1].substr(4) # Remove "Tier" prefix
				var tier_idx: int = int(tier_str)
				var type_idx: int = GenumHelper.MATERIAL_TYPE.values().find(material_type)
				
				if tier_idx < tier_names.size() and type_idx >= 0:
					var tier_name: String = tier_names[tier_idx]
					var type_name: String = type_names[type_idx]
					materials_text += "%s %s: %d\n" % [tier_name, type_name, material_counts[key]]
	
	materials_display.text = materials_text

func _on_refresh_materials() -> void:
	_refresh_materials_display()
#endregion
