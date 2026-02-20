## The Item resource type for declaration with every single item in the game.
class_name Item extends Resource

#region Declarations
@export var i_name : StringName
@export var value : int
@export var tags : Array[Genum.ItemTags]
@export var texture : Vector2i
@export var tooltip : String
@export var tier : int
@export var equip_loc : Genum.EquipLocation = Genum.EquipLocation.INVENTORY
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
	var dmh = DataManipulationHelper.new()
	value = dmh.detect_special_data(data.get("value"))
	tags = dmh.detect_special_data(data.get("tags"))
	texture = dmh.detect_special_data(data.get("texture"))
	tooltip = dmh.detect_special_data(data.get("tooltip"))
	tier = dmh.detect_special_data(data.get("tier"))
	equip_loc = dmh.detect_special_data(data.get("equip_loc"))
	max_stack_size = dmh.detect_special_data(data.get("max_stack_size"))

## Saves the item data into a CSV, often by using CreativeTools
func save_data() -> Dictionary:
	var dmh = DataManipulationHelper.new()
	var data : Dictionary = {
		"value": "%s" % value,
		"tags": "%s" % dmh.encode_special_data(tags),
		"texture": "%s" % dmh.encode_special_data(texture),
		"tooltip": tooltip,
		"tier": "%s" % tier,
		"equip_loc": "%s" % equip_loc,
		"max_stack_size": "%s" % max_stack_size
	}
	return data
#endregion
