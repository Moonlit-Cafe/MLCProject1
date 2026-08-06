## The Item resource child for eqiuppable items specifically as they need a bit of extra data.
class_name EquippableItem extends Item

# TODO: Init function checks power core aspects and determines if item has affinity
@export var aspect : Genum.AspectType
@export var set_id : int
@export var stats : Array[StatPacket]
@export var rarity : Genum.Rarity

func load_data(data: Dictionary) -> void:
	super(data)
	set_id = data.get("set_id")
