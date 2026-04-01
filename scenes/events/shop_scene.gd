extends BaseEventScene

@export var mat_slots : HBoxContainer
@export var use_slots : HBoxContainer
@export var eqp_slots : HBoxContainer

@export var slot_scene : PackedScene

# FIXME: There's regual inventory movement mechanics within the shop, we'll section it off later.
# TODO Tyler Add money to player
	# make enemies drop money on die
	# make enemies drop items on die (sometimes)
# TODO Tyler Make shop interact with buttons right
	# Add item to p inventory # This will need to be a sub function
	# take item from s stock
	# take p money
	# TODO Tyler Add checks for money later
	
# TODO Tyler need to make the shop slots their own inherited class
	# these should be loaded in programatically
	# Disable ability to drag items in/out
	# add click to buy func
	
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
			slot.generate_item(item.i_name)
			slot.held_item.setup_item(item)

func _on_pressed() -> void:
	SceneManager.load_next_scene()
