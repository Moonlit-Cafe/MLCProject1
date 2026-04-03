extends BaseEventScene

@export var mat_slots : HBoxContainer
@export var use_slots : HBoxContainer
@export var eqp_slots : HBoxContainer

@export var slot_scene : PackedScene

# FIXME: There's regual inventory movement mechanics within the shop, we'll section it off later.
	
# TODO Tyler Add money to game
	# make enemies drop money on die
	# make enemies drop items on die (sometimes later but always for now)
func _ready() -> void:
	var slot_boxes = [mat_slots,
					use_slots,
					eqp_slots]
					
	_generate_shop(slot_boxes)
	_fill_slots(slot_boxes)
	
func _generate_shop(slot_boxes) -> void:
	var t 
	for box in slot_boxes:
		t = randi_range(1, 5)
		for i in range(t):
			var new_slot = slot_scene.instantiate()
			box.add_child(new_slot)
	return

func _fill_slots(slot_boxes) -> void:
	for box in slot_boxes:
		for slot in box.get_children():
			var item := CraftManager.get_valued_items(0, 10, 1)[0]
			slot.generate_item(item.id)
			slot.held_item.item = item

func _on_pressed() -> void:
	SceneManager.load_next_scene()
