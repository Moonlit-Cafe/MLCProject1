## The Autoload in charge of handling crafting requests along with loading all the data.
extends Node

signal craft_request ## Signal called when ever a craft is requested via [method craft].

@export var texture_atlas : Texture2D ## The atlas reference to use for giving item nodes their texture (W.I.P.)
@export var texture_grid_size : Vector2i ## The size of each texture in [member texture_atlas]

@export var recipe_compendium : RecipeCompendium ## Reference to the Recipe Compendium used for the game

var available_to_craft : Array[Item] ## All available items to craft since last [method request_craft_list] call

#region Built-Ins
func _ready() -> void:
	# Initialize both compendiums so that their data is available.
	recipe_compendium.init()
#endregion

#region Public Methods
# TODO: Later on, I want to try and improve the performance on this, with the way it's currently designed
# it iterates on ALL the recipes rather than smart searches.

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
func craft(i_name: StringName, inventory: GridContainer) -> void:
	# Check if there's space available before crafting.
	var available_slot := find_free_slot(inventory)
	
	# Load up recipes and determine which items are available to craft with.
	var recipe = recipe_compendium.recipes.get(i_name.to_snake_case())
	for slot in inventory.get_children():
		var node = slot.held_item
		if not node:
			continue
		
		if node.item is not MaterialItem:
			continue
		
		if node.item.tier == recipe.get(&"tier"):
			var mat_type = GenumHelper.MATERIAL_TYPE.get(node.item.material_type)
			if recipe.get(mat_type) > 0:
				node.remove_from_stack(recipe.get(mat_type))
	
	if not _craft_item(i_name, 1, inventory):
		push_warning("There was no space in the inventory.")

func _craft_item(i_name: StringName, count: int, inventory: GridContainer) -> bool:
	for slot in inventory.get_children():
		if not slot.held_item:
			continue
		
		if slot.held_item.item.i_name == i_name:
			slot.held_item.add_to_stack(count)
			return true
	
	for slot in inventory.get_children():
		if not slot.held_item:
			slot.generate_item(i_name, count)
			return true
	
	return false
#endregion

#region Helper Methods
## Finds if an item is available in the ItemCompendium by it's StringName.
func find_item(item_name: StringName) -> Item:
	for item in ResourceManager.item_compendium.values():
		if item.i_name.to_snake_case() == item_name:
			return item
	
	push_warning("There is no item by the name " + item_name)
	return null

## Finds if an item is available in the ItemCompendium by it's ID.
func find_item_by_id(id: StringName) -> Item:
	for item in ResourceManager.item_compendium.values():
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
			continue
		material_list.get(node.item.tier).set(GenumHelper.MATERIAL_TYPE.get(node.item.material_type), node.count)
	
	return material_list

## Used to find if there is available inventory space within a given inventory.
func find_free_slot(inventory: GridContainer) -> InventorySlot:
	for slot in inventory.get_children():
		if not slot is InventorySlot:
			continue
		
		if not slot.held_item:
			return slot
	
	return null

## Used to find how many open spaces are available in an inventory
func calc_inv_space(avail_space: Array) -> int:
	var count : int = 0
	for y in avail_space:
		for x in y:
			if x:
				count += 1
	
	return count

func add_item_to_inv(i_name: StringName, inv_rect: Vector2i, available_space: Array, inventory: Array[ItemNode]) -> bool:
	for y in range(inv_rect.y):
			for x in range(inv_rect.x):
				if not available_space.get(y).get(x):
					continue
				var new_node := ItemNode.new()
				new_node.item = find_item(i_name)
				new_node.count = 1
				new_node.inv_pos = Vector2i(x, y)
				inventory.append(new_node)
				return true
	
	return false
#endregion

#region Added Functionality
# Check if a specific item can be crafted
func can_craft_item(item_name: , inventory: Array[ItemNode]) -> bool:
	var recipe = recipe_compendium.recipes.get(item_name.to_snake_case())
	if not recipe:
		return false
	
	var material_list = derive_materials(inventory)
	var tier = recipe.get(&"tier")
	
	if tier >= material_list.size():
		return false
	
	var mat_list = material_list.get(tier)
	for mat in mat_list.keys():
		if recipe.get(mat, 0) > mat_list.get(mat):
			return false
	
	return true

# Get the materials required for a recipe
func get_recipe_requirements(item_name: StringName) -> Dictionary:
	var recipe = recipe_compendium.recipes.get(item_name.to_snake_case())
	if not recipe:
		return {}
	
	return recipe

func get_compendium_size() -> int:
	return ResourceManager.get_data_count(ResourceManager.DataType.ITEM)
#endregion

## Grabs the specific portion of the texture to then set to the ItemNode's texture
# TODO: Implement this with the new ItemNode structure. Will have to wait till after
# fully implementing ItemNodes with the Inventory Github Branch.
func get_item_texture(pos: Vector2i) -> AtlasTexture:
	var return_texture := AtlasTexture.new()
	return_texture.atlas = texture_atlas
	return_texture.region = Rect2(pos * texture_grid_size.x, texture_grid_size)
	return return_texture

func get_random_item() -> Item:
	var idx = randi_range(0, ResourceManager.get_data_count(ResourceManager.DataType.ITEM))
	var item_type : String = ""
	var item_type_int = randi_range(0, ResourceManager.ItemType.size()) as ResourceManager.ItemType
	match(item_type_int):
		ResourceManager.ItemType.MATERIAL:
			item_type = "MAT_%s"
		_:
			item_type = "Null"
	var item : Item = ResourceManager.item_compendium.get(item_type % idx)
	return item
