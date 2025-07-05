## The Autoload in charge of handling crafting requests along with loading all the data.
extends Node

@export var texture_atlas : Texture2D
@export var texture_grid_size : Vector2i

@export var item_compendium : ItemCompendium
@export var recipe_compendium : RecipeCompendium

func _ready() -> void:
	recipe_compendium.init()
	print(recipe_compendium.recipes)

func _load_items() -> void:
	pass

func _create_recipes() -> void:
	pass

func _find_recipes_with_ingredients(items: Array[Item]) -> Recipe:
	if items.size() == 0:
		return null
	
	var recipes : Array[Recipe] = []
	for i in range(items.size()):
		if i == 0:
			recipes = _find_recipes_with(items.get(i))
		recipes = _find_recipes_with(items.get(i), recipes)
	
	for recipe in recipes:
		if _check_craftability(recipe, items):
			print(recipe.result)
			return recipe
	
	return null

func _find_recipes_with(item: Item, recipes: Array = []) -> Array[Recipe]:
	var available_recipes : Array[Recipe]
	if recipes == []:
		for recipe in recipe_compendium.recipes:
			if item in recipe.components:
				available_recipes.append(recipe)
	else:
		for recipe in recipes:
			if item in recipe.components:
				available_recipes.append(recipe)
	
	return available_recipes

func _check_craftability(recipe: Recipe, items: Array[Item]) -> bool:
	if recipe.components.size() != items.size():
		return false
	
	for item in items:
		if not recipe.components.has(item):
			return false
	
	return true

## The method used to craft an item
func request_craft(items: Array[Item]) -> Item:
	var recipe : Recipe = _find_recipes_with_ingredients(items)
	if not recipe:
		var warning_str : String = ""
		for item in items:
			warning_str += item.item_name + " "
		push_warning("There is no recipe for ingredients " + warning_str)
		return null
	
	return recipe.result

func find_item(item_name: StringName) -> Array:
	for item_set in item_compendium.sets:
		for tier in item_set.item_set.keys():
			if item_name == item_set.item_set.get(tier).item_name:
				return [item_set, tier, item_set.item_set.get(tier)]
	
	push_warning("There is no item by the name %s" % item_name)
	return [null]

# TODO: Document the CraftManager

func get_item_texture(pos: Vector2i) -> AtlasTexture:
	var return_texture := AtlasTexture.new()
	return_texture.atlas = texture_atlas
	return_texture.region = Rect2(pos * texture_grid_size, texture_grid_size)
	return return_texture
