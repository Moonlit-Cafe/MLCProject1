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

## Checks to see if the recipe is craftable given all the material items within an inventory
func is_craftable(inventory: Inventory) -> bool:
	var material_slots := inventory.get_all_with_tag(BasicItem.Tags.MATERIAL)
	
	var check_dict : Dictionary[StringName, bool] = {}
	for ingredient in ingredients.keys():
		check_dict.set(ingredient, false)
	
	for slot in material_slots:
		if not check_dict.has(slot.item.id):
			continue
		
		if slot.quantity >= ingredients.get(slot.item.id):
			check_dict.set(slot.item.id, true)
	
	for check in check_dict:
		if not check:
			return false
	
	return true
	#if !ingredients.has_all(items.keys()):
	#	return false # Returns false if all of the items are not included in the recipes ingredients list
	#
	#var can_craft : bool = true
	#for item in items.keys():
	#	var item_count : int = items.get(item)
	#	if not ingredients.has(item):
	#		continue
	#	
	#	if ingredients.get(item) > item_count:
	#		can_craft = false
	#return can_craft
#endregion
