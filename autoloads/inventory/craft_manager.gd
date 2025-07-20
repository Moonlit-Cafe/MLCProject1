## The Autoload in charge of handling crafting requests along with loading all the data.
extends Node

signal craft_request

@export var texture_atlas : Texture2D
@export var texture_grid_size : Vector2i

@export var item_compendium : ItemCompendium
@export var recipe_compendium : RecipeCompendium

var available_to_craft : Array[Item]

func _ready() -> void:
	item_compendium.init()
	recipe_compendium.init()

## TODO: When inventory is introduced there's a much better way of implementing this.
func craft(i_name: StringName, inventory: Array[Array]) -> Array[Array]:
	var recipe = recipe_compendium.recipes.get(i_name.to_snake_case())
	for item in inventory:
		if item.get(0) is not MaterialItem:
			continue
		
		if item.get(0).tier == recipe.get(&"tier"):
			var mat_type = GenumHelper.MATERIAL_TYPE.get(item.get(0).material_type)
			if recipe.get(mat_type) > 0:
				item.set(1, item.get(1) - recipe.get(mat_type))
	
	var item_found = false
	for item in inventory:
		if item.get(0) == find_item(i_name):
			item_found = true
			item.set(1, item.get(1) + 1)
	
	if not item_found:
		inventory.append([find_item(i_name), 1])
	return inventory

func derive_materials(inventory: Array[Array]) -> Array[Dictionary]:
	var material_list : Array[Dictionary] = []
	var material_line := {
		&"cloth": 0,
		&"leather": 0,
		&"dust": 0,
		&"metal": 0,
		&"wood": 0
	}
	for i in range(7):
		material_list.append(material_line)
	
	for item in inventory:
		if item.get(0) is not MaterialItem:
			continue
		material_list.get(item.get(0).tier).set(GenumHelper.MATERIAL_TYPE.get(item.get(0).material_type), item.get(1))
	
	return material_list

## The method used to craft an item
func request_craft_list(inventory: Array[Array]) -> void:
	available_to_craft = []
	
	var material_list = derive_materials(inventory)
	
	for recipe in recipe_compendium.recipes.keys():
		var recipe_array = recipe_compendium.recipes.get(recipe)
		var can_craft := true
		var tier = recipe_array.get(&"tier")
		for i in range(material_list.size()):
			if i != tier:
				continue
			
			var mat_list = material_list.get(i)
			for mat in mat_list.keys():
				if recipe_array.get(mat) <= mat_list.get(mat):
					continue
				else:
					can_craft = false
		
		if can_craft:
			available_to_craft.append(find_item(recipe))
	
	craft_request.emit()

func find_item(item_name: StringName) -> Item:
	for item in item_compendium.item_reference:
		if item.i_name.to_snake_case() == item_name:
			return item
	
	push_warning("There is no item by the name " + item_name)
	return null

func find_item_by_id(id: int) -> Item:
	for item in item_compendium.item_reference:
		if item.id == id:
			return item
	
	push_warning("There is no item by the name %s" % id)
	return null

# TODO: Document the CraftManager

func get_item_texture(pos: Vector2i) -> AtlasTexture:
	var return_texture := AtlasTexture.new()
	return_texture.atlas = texture_atlas
	return_texture.region = Rect2(pos * texture_grid_size, texture_grid_size)
	return return_texture
