## Contains every recipe found within the game
class_name RecipeCompendium extends Resource

@export_file(".csv") var recipe_path : String
var recipes : Dictionary

func init() -> void:
	if recipe_path:
		var loaded_recipes = FileHelper.load_asset(recipe_path).records
		for recipe in loaded_recipes:
			var recipe_name = recipe.get(&"RecipeName").to_snake_case()
			recipes[recipe_name] = {
				&"Tier": recipe.get(&"Tier", 0),
				&"Cloth": recipe.get(&"Cloth"),
				&"Leather": recipe.get(&"Leather"),
				&"Wood": recipe.get(&"Wood"),
				&"Metal": recipe.get(&"Metal"),
				&"Dust": recipe.get(&"Dust"),
				&"Core": recipe.get(&"Core"),
				&"BossMaterial": recipe.get(&"BossMaterial")
			}
