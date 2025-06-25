## Holds data of a specific type of item and all of its tiers.
class_name ItemSet extends Resource

@export var group_name : StringName
@export var item_set : Dictionary[Genum.ItemTier, Item]
@export var max_stack : int = 1
