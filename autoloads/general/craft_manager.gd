## The Autoload in charge of handling crafting requests along with loading all the data.
class_name CraftManager extends Node

signal craft_request ## Signal called when ever a craft is requested via [method craft].

@export var texture_atlas : Texture2D ## The atlas reference to use for giving item nodes their texture (W.I.P.)
@export var texture_grid_size : Vector2i ## The size of each texture in [member texture_atlas]
@export_file(".json") var recipe_data_path : String ## Reference to the Recipe Compendium used for the game
@export var item_node : PackedScene
@export var equip_node : PackedScene
@export var weapon_node : PackedScene

var available_to_craft : Array[Item] ## All available items to craft since last [method request_craft_list] call
var recipe_compendium : Dictionary[String, Recipe]

#region Events
func _ready() -> void:
	await GameGlobal.ready
	GameGlobal.logging.post_message(self, "Loading Recipes")
	_load_recipes()

func _load_recipes() -> void:
	if not recipe_data_path:
		GameGlobal.logging.post_warning(self, "There is no referenced recipe database file.")
	var loaded_recipes : Dictionary = FileHelper.load_database(recipe_data_path)
	for id in loaded_recipes.keys():
		var recipe = Recipe.new()
		recipe.load_data(loaded_recipes.get(id))
		recipe_compendium.set(id, recipe)

## Grabs the specific portion of the texture to then set to the ItemNode's texture
# TODO: Implement this with the new ItemNode structure. Will have to wait till after
# fully implementing ItemNodes with the Inventory Github Branch.
func get_item_texture(pos: Vector2i) -> AtlasTexture:
	var return_texture := AtlasTexture.new()
	return_texture.atlas = texture_atlas
	return_texture.region = Rect2(pos * texture_grid_size.x, texture_grid_size)
	return return_texture

func get_random_item(rand_type = null, item_id:int = -1) -> Item:
	if rand_type == null:
		rand_type = randi_range(0, ResourceManager.ItemType.size()) as ResourceManager.ItemType
		
	if item_id == -1:
		item_id = GameGlobal.resources.get_data_count(ResourceManager.DataType.ITEM, rand_type)
		item_id = max(item_id-1, 0)
		item_id = randi_range(0, item_id)
	
		
	var type_str : String = ""
	match(rand_type):
		ResourceManager.ItemType.MATERIAL:
			type_str = "MAT_%s"
		ResourceManager.ItemType.USABLE:
			type_str = "USE_%s"
		ResourceManager.ItemType.EQUIPPABLE:
			type_str = "EQP_%s"
		ResourceManager.ItemType.WEAPON:
			type_str = "WEP_%s"
		_:
			type_str = "NULL_%s"
	
	var item : Item = GameGlobal.resources.item_compendium.get(type_str % item_id)
	if not item:
		return
	print("Added Item: %s" % item.i_name)
	return item

func get_valued_items(min_value:int, max_value:int, count:int, _rand_type = null, _item_id:int=-1)->Array[Item]:
	# Get a Sub compendium based on item values
	# Pull a random item from it 
	if count < 1:
		return []
	
	var names = _value_range_compendium(min_value, max_value)
	if not names:
		GameGlobal.logging.post_warning(self, "No item within range of [%s : %s]" % [min_value, max_value])
		return []
	
	var thing : Array[Item]
	for i in range(count):
		thing.append(GameGlobal.resources.item_compendium.get(names[randi_range(0, names.size()-1)]))
	return thing


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
		GameGlobal.logging.post_warning(self, "There was no space in the inventory.")

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
func _value_range_compendium(min_value:int, max_value:int) -> Array[StringName]:
	if max_value < min_value:
		GameGlobal.logging.post_warning(self, "Invalid range of values queried! [%s : %s]" % [min_value, max_value])
		return []
	
	var item_names:Array[StringName] =  []
	var cur_item
	for item in GameGlobal.resources.item_compendium:
		cur_item = GameGlobal.resources.item_compendium[item]
		if cur_item.value <= max_value and cur_item.value >= min_value:
			item_names.append(item)
	return item_names
	
func generate_node(in_item: Item = null, item_id: StringName = &"MAT_0") -> ItemNode:
	if not in_item:
		in_item = find_item_by_id(item_id)
	else:
		item_id = in_item.id
	
	if not in_item:
		GameGlobal.logging.post_warning(self, "Couldn't find any item . . . skipping.")
		return
	
	var node
	match in_item.equip_loc:
		Genum.EquipLocation.INVENTORY:
			node = item_node
		Genum.EquipLocation.WEAPON:
			node = weapon_node
		_:
			node = equip_node
		
	node = node.instantiate()
	node.item = in_item
	return node

## Finds if an item is available in the ItemCompendium by it's StringName.
func find_item(item_name: StringName) -> Item:
	for item in GameGlobal.resources.item_compendium.values():
		if item.i_name.to_snake_case() == item_name:
			return item
	
	GameGlobal.logging.post_warning(self, "There is no item by the name %s" % item_name)
	return null

## Finds if an item is available in the ItemCompendium by it's ID.
func find_item_by_id(id: StringName) -> Item:
	for item in GameGlobal.resources.item_compendium.values():
		if item.id == id:
			return item
	
	GameGlobal.logging.post_warning(self, "There is no item by the name %s" % id)
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
	return GameGlobal.resources.get_data_count(ResourceManager.DataType.ITEM)
#endregion
