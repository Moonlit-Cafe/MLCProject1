## Manages a specific recipe for an item.
class_name Recipe extends Resource

#region Declarations
@export var ingredients : Dictionary[StringName, int] = {} # The ingredients for the recipe based on IDs
@export var result : StringName = &"" # The result of the recipe
@export var count : int = 1 # How much of the result comes from the recipe
#endregion

#region Statics
static func generate_recipe(items: Dictionary[StringName, int], new_item: StringName, amount: int) -> Recipe:
	var recipe := Recipe.new()
	recipe.ingredients = items
	recipe.result = new_item
	recipe.count = amount
	return recipe
#endregion

#region Events
func craft() -> void:
	pass

func is_craftable(inventory: Inventory) -> bool:
	if inventory == null:
		return false
	
	var available : Dictionary[StringName, int] = {}
	for slot in inventory.get_all_with_tag(BasicItem.Tags.MATERIAL):
		if slot.is_empty():
			continue
		available[slot.item.id] = available.get(slot.item.id, 0) + slot.quantity
	
	for ingredient : StringName in ingredients.keys():
		if available.get(ingredient, 0) < ingredients.get(ingredient):
			return false
	
	return true
#endregion
