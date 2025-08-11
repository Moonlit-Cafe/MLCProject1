extends CanvasLayer

@export var rand_item : Item

@export var container : GridContainer
@export var inv_size := Vector2i(5, 5)
@export var inv_slot : PackedScene

@export var inv_node : PackedScene

func _ready() -> void:
	if container:
		container.columns = inv_size.x
	
	_generate_inventory()

func _generate_inventory() -> void:
	for y in range(inv_size.y):
		#inventory.append([])
		for x in range(inv_size.x):
			var new_slot : InventorySlot = inv_slot.instantiate()
			new_slot.inv_position = Vector2i(x, y)
			container.add_child(new_slot)
	for slot in range(inv_size.x * inv_size.y):
		var new_slot : InventorySlot = inv_slot.instantiate()
		container.add_child(new_slot)

func _generate_random_itemnodes(count: int) -> void:
	for node in range(count):
		var slot = container.get_child(randi_range(0, inv_size.x * inv_size.y - 1))
		while slot.get_child_count() > 0:
			slot = container.get_child(randi_range(0, inv_size.x * inv_size.y - 1))
		
		var new_node : ItemNode = inv_node.instantiate()
		new_node.setup_item(rand_item, 50)
		slot.add_child(new_node)
