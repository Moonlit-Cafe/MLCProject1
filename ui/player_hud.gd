extends CanvasLayer

@export var rand_items : Array[Item]

@export var inventory : HBoxContainer

@export var container : GridContainer
@export var inv_size := Vector2i(5, 5)
@export var inv_slot : PackedScene

@export var inv_node : PackedScene

var hidden := true

func _ready() -> void:
	if container:
		container.columns = inv_size.x
	
	_generate_inventory()
	_generate_random_itemnodes()
	hide_inv()

func _input(event: InputEvent) -> void:
	# TODO: Check if allowed to open inventory
	if event.is_action_pressed("toggle_inventory"):
		if hidden:
			show_inv()
		else:
			hide_inv()

func _generate_inventory() -> void:
	for slot in range(inv_size.x * inv_size.y):
		var new_slot : InventorySlot = inv_slot.instantiate()
		container.add_child(new_slot)

func _generate_random_itemnodes() -> void:
	for item in rand_items:
		var slot = container.get_child(randi_range(0, inv_size.x * inv_size.y - 1))
		while slot.get_child_count() > 0:
			slot = container.get_child(randi_range(0, inv_size.x * inv_size.y - 1))
		
		var new_node : ItemNode = inv_node.instantiate()
		new_node.setup_item(item)
		slot.add_child(new_node)

func show_inv() -> void:
	var tween := create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(inventory, "position", Vector2(0, 0), 0.5)
	hidden = false

func hide_inv() -> void:
	var tween := create_tween().bind_node(self).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(inventory, "position", Vector2(-inventory.size.x, 0), 0.5)
	hidden = true
