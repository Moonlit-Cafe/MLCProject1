## The Autoload in charge of handling crafting requests along with loading all the data.
extends Node

@export var texture_atlas : Texture2D
@export var texture_grid_size : Vector2i

@export var item_compendium : ItemCompendium
@export var recipe_compendium : RecipeCompendium

var available_to_craft : Array[Item]

func _ready() -> void:
	recipe_compendium.init()

## The method used to craft an item
func request_craft_list(materials: Array[Item]) -> Array[Item]:
	available_to_craft = []
	for recipe in recipe_compendium.recipes.keys():
		var recipe_array = recipe.compendium.recipes.get(recipe)
		var can_craft := true
		var tier = recipe_array.get(&"tier")
		for mat in materials.get(tier):
			if recipe_array.get(mat.get(0)) <= mat.get(1):
				continue
			else:
				can_craft = false
		
		if can_craft:
			available_to_craft.append(find_item(recipe))
	
	return available_to_craft


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
