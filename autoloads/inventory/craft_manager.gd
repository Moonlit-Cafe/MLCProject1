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
func craft(i_name: StringName, inv_rect: Vector2i, inventory: Array[ItemNode]) -> Array[ItemNode]:
	var recipe = recipe_compendium.recipes.get(i_name.to_snake_case())
	for node in inventory:
		if node.item is not MaterialItem:
			continue
		
		if node.item.tier == recipe.get(&"tier"):
			var mat_type = GenumHelper.MATERIAL_TYPE.get(node.item.material_type)
			if recipe.get(mat_type) > 0:
				node.count -= recipe.get(mat_type)
	
	var item_found = false
	for node in inventory:
		if node.item == find_item(i_name):
			item_found = true
			node.count += 1
	
	var available_space = find_inv_space(inv_rect, inventory)
	
	if not item_found:
		var space_found := false
		for y in range(inv_rect.y):
			for x in range(inv_rect.x):
				if available_space.get(y).get(x):
					var new_node := ItemNode.new()
					new_node.item = find_item(i_name)
					new_node.count = 1
					new_node.inv_pos = Vector2i(x, y)
					inventory.append(new_node)
					space_found = true
					break
		
		if not space_found:
			push_warning("There was no space in the inventory for the item.")
	return inventory

func find_inv_space(inv_rect: Vector2i, inventory: Array[ItemNode]) -> Array:
	var spaces = []
	for y in range(inv_rect.y):
		var y_arr = []
		for x in range(inv_rect.x):
			y_arr.append(true)
		spaces.append(y_arr)
	
	for node in inventory:
		spaces.get(node.inv_pos.y).set(node.inv_pos.x, false)
	
	return spaces

func derive_materials(inventory: Array[ItemNode]) -> Array[Dictionary]:
	var material_list : Array[Dictionary] = []
	var material_line := {
		&"cloth": 0,
		&"leather": 0,
		&"dust": 0,
		&"metal": 0,
		&"wood": 0
	}
	for i in range(Genum.Rarity.size()):
		material_list.append(material_line)
	
	for node in inventory:
		if node.item is not MaterialItem:
			print(node.item.i_name)
			continue
		material_list.get(node.item.tier).set(GenumHelper.MATERIAL_TYPE.get(node.item.material_type), node.count)
	
	return material_list

## The method used to craft an item
func request_craft_list(inventory: Array[ItemNode]) -> void:
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
