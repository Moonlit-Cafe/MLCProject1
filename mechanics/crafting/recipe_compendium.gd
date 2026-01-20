## Contains every recipe found within the game
class_name RecipeCompendium extends Resource

@export_file(".csv") var compendium_path : String
var recipes : Dictionary

func init() -> void:
	if compendium_path:
		var loaded_recipes = FileHelper.load_asset(compendium_path).records
		for recipe in loaded_recipes:
			var recipe_name = recipe.get(&"RecipeName").to_snake_case() as String
			recipe.erase(&"RecipeName")
			var temp_d = {}
			for line in recipe.keys() :
				var name = line
				var val = recipe[line]
				temp_d.get_or_add(name, val)
			recipes[recipe_name] = temp_d
		print(recipes)
