## Contains every recipe found within the game
class_name RecipeCompendium extends Resource

@export_file(".csv") var compendium_path : String
var recipes : Dictionary

func init() -> void:
	if compendium_path:
		var loaded_recipes = FileHelper.load_asset(compendium_path).records
		for recipe in loaded_recipes:
			var recipe_name = recipe.get(&"RecipeName").to_snake_case()
			recipes[recipe_name] = {
				&"tier": recipe.get(&"Tier", 0),
				&"cloth": recipe.get(&"Cloth"),
				&"leather": recipe.get(&"Leather"),
				&"wood": recipe.get(&"Wood"),
				&"metal": recipe.get(&"Metal"),
				&"dust": recipe.get(&"Dust"),
				&"core": recipe.get(&"Core"),
				&"boss_material": recipe.get(&"BossMaterial"),
				&"discovered": false
			}
