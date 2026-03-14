extends CanvasLayer

#region Declarations
@export var inventory : HBoxContainer

@export var container : GridContainer
@export var inv_size := Vector2i(5, 5)
@export var inv_slot : PackedScene

@export var inv_node : PackedScene
@export var wep_node : PackedScene

@export var item_manager : ItemManager

@onready var tab_container : TabContainer = $TabContainer

var hidden := true
#endregion

func _ready() -> void:
	add_to_group(&"inventory")
	
	if container:
		container.columns = inv_size.x
		
	item_manager = CombatManager.item_manager
	
	_generate_inventory()
	_generate_random_itemnodes()
	await GameGlobal.delay(0.5)
	hide_inv()

func _input(event: InputEvent) -> void:
	# TODO: Check if allowed to open inventory
	if event.is_action_pressed("inventory"):
		if hidden:
			show_inv()
		else:
			hide_inv()

func _generate_inventory() -> void:
	for slot in range(inv_size.x * inv_size.y):
		var new_slot : InventorySlot = inv_slot.instantiate()
		container.add_child(new_slot)

func _generate_random_itemnodes() -> void:
	var rand_items : Array[Item] = []
	for i in range(2):
		rand_items.append(_random_item())
	
	print(rand_items)
	
	for i in range(3):
		rand_items.append(_random_item(ResourceManager.ItemType.EQUIPPABLE, i))
		
	for item in rand_items:
		var slot = container.get_child(randi_range(0, inv_size.x * inv_size.y - 1))
		while slot.get_child_count() > 0:
			slot = container.get_child(randi_range(0, inv_size.x * inv_size.y - 1))
		
		var new_node
		if item is WeaponItem:
			new_node = wep_node.instantiate()
		else:
			new_node = inv_node.instantiate()
		new_node.setup_item(item)
		slot.add_child(new_node)
		
func _random_item(rand_type = null, item_count = null):
	if rand_type == null:
		rand_type = randi_range(0, ResourceManager.ItemType.size()) as ResourceManager.ItemType
	if item_count == null:
		item_count = ResourceManager.get_data_count(ResourceManager.DataType.ITEM, rand_type)
		
	if item_count <= 0:
		rand_type = ResourceManager.ItemType.MATERIAL
		item_count = ResourceManager.get_data_count(ResourceManager.DataType.ITEM, rand_type)
		
	var idx = randi_range(0, item_count - 1)
	print(idx)
	var type_str : String = ""
	match(rand_type):
		ResourceManager.ItemType.MATERIAL:
			type_str = "MAT_%s"
		ResourceManager.ItemType.USABLE:
			type_str = "USE_%s"
		ResourceManager.ItemType.EQUIPPABLE:
			type_str = "EQP_%s"
		ResourceManager.ItemType.WEAPON:
			type_str = "WEP_%s"
		_:
			type_str = "Null"
	
	var item : Item = ResourceManager.item_compendium.get(type_str % idx)
	print("Added Item: %s" % item.i_name)
	return item
		
	# TODO TYLER add Bomba items to rand_items
	# TODO TYLER add Bomba items to compendiums
	# TODO TYLER add bomba item set effect to data
		
	

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
