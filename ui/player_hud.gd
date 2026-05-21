extends CanvasLayer

#region Declarations
@export var inventory : HBoxContainer
@onready var equip_slots = $TabContainer/Inventory/EquipmentContainer/MarginContainer/GridContainer.get_children()

@export var container : GridContainer
@export var inv_size := Vector2i(5, 5)
@export var inv_slot : PackedScene

@export var item_manager : ItemManager

@onready var tab_container : TabContainer = $TabContainer

var hidden := true
#endregion

#region Events
func _ready() -> void:
	add_to_group(&"inventory")
	
	PlayerManager.inventory = self
	
	if container:
		container.columns = inv_size.x
		
	item_manager = CombatManager.item_manager
	
	_connect_equip_slots()
	
	_generate_inventory()
	_generate_random_itemnodes()
	await GameGlobal.delay()
	hide_inv()
	

func _input(event: InputEvent) -> void:
	# TODO: Check if allowed to open inventory
	if event.is_action_pressed("inventory"):
		if hidden:
			show_inv()
		else:
			hide_inv()

func _connect_equip_slots() -> void:
	for slot in equip_slots:
		slot.check_set.connect(_check_sets)
	
	_check_sets()
		
func _check_sets() -> void:
	if GameGlobal.resources.set_compendium.size() == 0:
		return
	var equipped_sets = _count_sets()
	var bonuses : PackedByteArray
	if ResourceManager.set_compendium.keys().max():
		bonuses.resize(ResourceManager.set_compendium.keys().max() + 1)
	else:
		bonuses.resize(0)
	

	for cur_set in equipped_sets:
		bonuses.set(cur_set,  
			int(equipped_sets[cur_set] >= GameGlobal.resources.set_compendium[cur_set]["required"])
		)
	
	PlayerManager.update_sets(bonuses)
	
	for slot:InventorySlot in equip_slots:
		if slot.held_item as EquippableNode:
			var cur_set = slot.held_item.item.set_id
			var equipped = equipped_sets[cur_set]
			var required = GameGlobal.resources.set_compendium[cur_set as int]["required"]
			var text_color = Color.DARK_GREEN if equipped >= required else Color.WHITE
			
			slot.held_item.count_label.text = "%s / %s" % [equipped,  required]
			slot.held_item.count_label.self_modulate = text_color
			
		else:
			slot.label.text = Genum.EquipLocation.keys()[slot.can_slot].substr(0,5)
			
func _count_sets() -> Dictionary:
	var counts = {}
	
	for slot : InventorySlot in equip_slots:
		if slot.held_item:
			var cur_set = slot.held_item.item.set_id
			if cur_set in counts.keys():
				counts[cur_set] = counts[cur_set] + 1
			else:
				counts[cur_set] = 1
				
	return counts
	

func _generate_inventory() -> void:
	for slot in range(inv_size.x * inv_size.y):
		var new_slot : InventorySlot = inv_slot.instantiate()
		container.add_child(new_slot)

func _generate_random_itemnodes() -> void:
	var rand_items : Array[Item] = []
	
	for i in range(3):
		rand_items.append(GameGlobal.craft.get_random_item(ResourceManager.ItemType.MATERIAL))
		rand_items.append(GameGlobal.craft.get_random_item(ResourceManager.ItemType.EQUIPPABLE, i))
	
	rand_items.append(GameGlobal.craft.get_random_item(ResourceManager.ItemType.EQUIPPABLE))
	print(rand_items)
		
	for item in rand_items:
		var slot = container.get_child(randi_range(0, inv_size.x * inv_size.y - 1))
		while slot.get_child_count() > 1:
			slot = container.get_child(randi_range(0, inv_size.x * inv_size.y - 1))
		
		var new_node = GameGlobal.craft.generate_node(item)
		new_node.item = item
		new_node.count = randi_range(1, item.max_stack_size)
		slot.add_child(new_node)
#endregion

#region Helpers
func get_slots() -> Array[InventorySlot]:
	var slots:Array[InventorySlot] = [] 
	for eqp_child in $TabContainer/Inventory/EquipmentContainer/MarginContainer/GridContainer.get_children():
		slots.append(eqp_child)
	
	for inv_child in $TabContainer/Inventory/InventoryContainer/MarginContainer/Inventory.get_children():
		slots.append(inv_child)
		
	return slots

func show_inv() -> void:
	var tween := create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(tab_container, "position", Vector2(0, 0), 0.5)
	hidden = false

func hide_inv() -> void:
	var tween := create_tween().bind_node(self).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(tab_container, "position", Vector2(-inventory.size.x, 0), 0.5)
	hidden = true

func get_usables() -> Array[Usable]:
	var usable_list : Array[Usable] = []
	
	for child in container.get_children():
		if not child.held_item:
			continue
		
		if child.held_item.item is UsableItem:
			var usable_data = item_manager.get_usable(child.held_item.item.id)
			if usable_data == null:
				continue
				
			usable_data.linked_slot = child
			
			usable_list.append(usable_data)
	
	return usable_list
#endregion
