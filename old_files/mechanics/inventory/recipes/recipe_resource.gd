class_name Recipe extends Resource

#region Declarations
@export var result : String = ""
@export var count : int = 1
@export var ingredients : Dictionary[String, int] = {}
@export var tier : Genum.Rarity = Genum.Rarity.MOTAL
#endregion

#region Events
func load_data(data: Dictionary) -> void:
	result = data.get("result")
	count = data.get("count")
	ingredients.assign(data.get("ingredients"))
	tier = int(data.get("tier")) as Genum.Rarity

func save_data() -> Dictionary:
	var save_dict : Dictionary = {
		"result": result,
		"count": count,
		"ingredients": ingredients,
		"tier": tier
	}
	return save_dict
#endregion
