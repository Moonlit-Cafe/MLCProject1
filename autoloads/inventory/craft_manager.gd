## The Autoload in charge of handling crafting requests along with loading all the data.
extends Node

signal craft_request ## Signal called when ever a craft is requested via [method craft].

@export var texture_atlas : Texture2D ## The atlas reference to use for giving item nodes their texture (W.I.P.)
@export var texture_grid_size : Vector2i ## The size of each texture in [member texture_atlas]

@export var item_compendium : ItemCompendium ## Reference to the Item Compendium used for the game
@export var recipe_compendium : RecipeCompendium ## Reference to the Recipe Compendium used for the game

var available_to_craft : Array[Item] ## All available items to craft since last [method request_craft_list] call

#region Built-Ins
func _ready() -> void:
	# Initialize both compendiums so that their data is available.
	item_compendium.init()
	recipe_compendium.init()
#endregion

#region Public Methods
## Takes all of the available inventory, determines which of it can be used in crafting and then
## updates [member available_to_craft] with all the recipes that one could make with the current
## set of materials.
func request_craft_list(inventory: Array[ItemNode]) -> void:
	# Empties the available_to_craft to prepare for a new list of recipes.
	available_to_craft = []
	
	# Grab the available materials to craft with.
	var material_list = derive_materials(inventory)
	
	# Iterate over all the recipes in the compendium to see if the recipe requirements
	# matches the materials available.
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

## Called when a craft is needed, will take in the name of the to-craft item's name, the size of the
## inventory to know where to place items, and the actual content of the inventory.
##
## There's potential for the method to be changed later due to inventory handling.
func craft(i_name: StringName, inv_rect: Vector2i, inventory: Array[ItemNode]) -> Array[ItemNode]:
	# Load up recipes and determine which items are available to craft with.
	var recipe = recipe_compendium.recipes.get(i_name.to_snake_case())
	for node in inventory:
		if node.item is not MaterialItem:
			continue
		
		if node.item.tier == recipe.get(&"tier"):
			var mat_type = GenumHelper.MATERIAL_TYPE.get(node.item.material_type)
			if recipe.get(mat_type) > 0:
				node.count -= recipe.get(mat_type)
	
	# Check to see if the item to be crafted exists within the inventory,
	# if so, then just increases the item's count or if the max stack is reached.
	# Creates a new item_node.
	var item_found = false
	for node in inventory:
		if node.item.i_name == i_name:
			item_found = true
			if node.count < node.item.max_stack:
				node.count += 1
			else:
				item_found = false
	
	# Checks to see if there's any available space in the inventory to hold the newly
	# crafted item.
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
#endregion

#region Helper Methods
## Finds if an item is available in the ItemCompendium by it's StringName.
func find_item(item_name: StringName) -> Item:
	for item in item_compendium.item_reference:
		if item.i_name.to_snake_case() == item_name:
			return item
	
	push_warning("There is no item by the name " + item_name)
	return null

## Finds if an item is available in the ItemCompendium by it's ID.
func find_item_by_id(id: int) -> Item:
	for item in item_compendium.item_reference:
		if item.id == id:
			return item
	
	push_warning("There is no item by the name %s" % id)
	return null

# Grabs all the material items from an Inventory and turns it into an array of dictionaries
# to make the processing of crafting easier.
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

## Used to find if there is available inventory space within a given inventory.
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

## Grabs the specific portion of the texture to then set to the ItemNode's texture
# TODO: Implement this with the new ItemNode structure. Will have to wait till after
# fully implementing ItemNodes with the Inventory Github Branch.
func get_item_texture(pos: Vector2i) -> AtlasTexture:
	var return_texture := AtlasTexture.new()
	return_texture.atlas = texture_atlas
	return_texture.region = Rect2(pos * texture_grid_size, texture_grid_size)
	return return_texture
#endregion
