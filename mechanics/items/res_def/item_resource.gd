## The Item resource type for declaration with every single item in the game.
class_name Item extends Resource

#region Declarations
@export var i_name : StringName
@export var id : int
@export var value : int
@export var tags : Array[Genum.ItemTags]
@export var texture : Vector2i
@export var tooltip : String
@export var tier : int
@export var equip_loc : Genum.EquipLocation = Genum.EquipLocation.INVENTORY
@export var max_stack_size : int = 99  # TODO: Set appropriate stack sizes per item type
#endregion

#region Helpers
## Get display name (fallback to resource name if i_name is empty)
func get_display_name() -> String:
	return i_name if i_name != "" else resource_name

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
#endregion
