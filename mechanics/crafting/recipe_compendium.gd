## Contains every recipe found within the game
class_name RecipeCompendium extends Resource

@export_file(".csv") var compendium_path : String
var recipes : Dictionary

func init() -> void:
	if compendium_path:
		var loaded_recipes = FileHelper.load_asset(compendium_path).records
		for recipe in loaded_recipes:
			var recipe_name = recipe.get(recipe.find(&"RecipeName")).to_snake_case()
			recipes[recipe_name] = {
				&"tier": recipe.get(recipe.find(&"Tier")),
				&"cloth": recipe.get(recipe.find(&"Cloth")),
				&"leather": recipe.get(recipe.find(&"Leather")),
				&"wood": recipe.get(recipe.find(&"Wood")),
				&"metal": recipe.get(recipe.find(&"Metal")),
				&"dust": recipe.get(recipe.find(&"Dust")),
				&"core": recipe.get(recipe.find(&"Core")),
				&"boss_material": recipe.get(recipe.find(&"BossMaterial")),
				&"discovered": false
			}
