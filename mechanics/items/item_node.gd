## An extension of Button to specifically act as the items for an inventory.
class_name ItemNode extends Button

@export var item_set : ItemSet
@export var item_tier : Genum.ItemTier = Genum.ItemTier.MUNDANE

var item : Item

# TODO: Need to make draggable, and maybe have a little animation while doing so.

# TODO: Need to also make a slot class where the items can then be "inserted" to for later. But for now
# will be what we need for crafting.

func _ready() -> void:
	if item_set != null:
		print("Got to this point")
		item = item_set.item_set.get(item_tier)
		icon = CraftManager.get_item_texture(item.item_texture)
		print(icon.get_size())
