## The Item resource type for declaration with every single item in the game.
class_name Item extends Resource

#region Declarations
@export var i_name : StringName
@export var value : int
@export var tags : Array[Genum.ItemTags]
@export var texture : Vector2i
@export var tooltip : String
@export var tier : int
@export var equip_loc : Genum.EquipSlot = Genum.EquipSlot.INVENTORY
@export var max_stack_size : int = 99  # TODO: Set appropriate stack sizes per item type

var id : StringName
#endregion

#region Helpers
## Get display name (fallback to resource name if i_name is empty)
func get_display_name() -> String:
	if i_name.is_empty():
		return resource_name
	else:
		return i_name

## Check if item has a specific tag
func has_tag(tag: Genum.ItemTags) -> bool:
	return tag in tags

## Get rarity/tier color for UI display
func get_tier_color() -> Color:
	match tier:
		Genum.Rarity.MOTAL: return Color.WHITE
		Genum.Rarity.PEBBLED: return Color.GREEN
		Genum.Rarity.COMETARY: return Color.BLUE
		Genum.Rarity.PLANETARY: return Color.PURPLE
		Genum.Rarity.STELLAR: return Color.ORANGE
		Genum.Rarity.NEBULOUS: return Color.DARK_GOLDENROD
		Genum.Rarity.COSMIC: return Color.SPRING_GREEN
		_: return Color.WHITE

## Load the item from a given set of data handled by ResourceManager
func load_data(data: Dictionary) -> void:
	i_name = data.get("name")
	value = data.get("value")
	tags.assign(data.get("tags"))
	texture = data.get("texture")
	tooltip = data.get("tooltip")
	tier = data.get("tier")
	equip_loc = data.get("equip_loc")
	max_stack_size = data.get("max_stack_size")

## Saves the item data into a CSV, often by using CreativeTools
func save_data() -> Dictionary:
	var data : Dictionary = {
		"value": value,
		"tags": tags,
		"texture": texture,
		"tooltip": tooltip,
		"tier": tier,
		"equip_loc": equip_loc,
		"max_stack_size": max_stack_size
	}
	return data

func get_manager_data() -> Dictionary[StringName, Variant]:
	var data : Dictionary[StringName, Variant] = {
		&"id": id,
		&"name": i_name,
		&"value": value,
		&"tags": tags,
		&"texture": texture,
		&"tooltip": tooltip,
		&"tier": tier,
		&"equip_loc": equip_loc,
		&"max_stack_size": max_stack_size
	}
	return data
#endregion
