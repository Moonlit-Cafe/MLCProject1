## Contains every recipe found within the game
class_name RecipeCompendium extends Resource

#region Declarations
@export_file(".csv") var compendium_path : String = "res://assets/data/item_recipes.csv" ## The path to the Recipes.CSV file
var recipes : Dictionary ## All of the recipes contained within [member compendium_path] in a readable, dictionary format.
#endregion

#region Events
## Initializes the compendium by having it read through all the data contined within
## [member compendium_path].
func init() -> void:
	if compendium_path:
		var loaded_recipes = CSVAccess.load_csv_data(compendium_path)
		for recipe_name in loaded_recipes.keys():
			var recipe = loaded_recipes.get(recipe_name)
			var recipe_dict = {}
			for line in recipe.keys():
				var name = line.to_snake_case()
				var val = recipe[line]
				recipe_dict.get_or_add(name, val)
			recipes[recipe_name.to_snake_case()] = recipe_dict
		print(recipes)
#endregion
