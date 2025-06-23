## The Autoload in charge of handling crafting requests along with loading all the data.
extends Node

@export var texture_atlas : Texture2D
@export var texture_grid_size : Vector2i

@export var item_compendium : ItemCompendium
@export var recipe_compendium : RecipeCompendium

@export var test_item_craft : Item

func _ready() -> void:
	var recipe := _find_recipes_with_ingredients([test_item_craft, test_item_craft])
	print(recipe.result.item_name)

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

# TODO: Work on adding public functions to get specific data regarding crafts and requests

# TODO: Document the CraftManager

# TODO: Make a test scene to ensure crafting is going as planned.

func get_item_texture(pos: Vector2i) -> AtlasTexture:
	var return_texture := AtlasTexture.new()
	return_texture.atlas = texture_atlas
	return_texture.region = Rect2(pos, texture_grid_size)
	return return_texture
