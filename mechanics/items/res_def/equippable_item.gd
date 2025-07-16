## The Item resource child for eqiuppable items specifically as they need a bit of extra data.
class_name EquippableItem extends Item

# TODO: Init function checks power core aspects and determines if item has affinity
@export var aspect : Genum.AspectType
@export var stats : Dictionary[Genum.StatType, int]
@export var slot_location : Genum.EquipLocation
@export var rarity : Genum.Rarity
var affinity : Genum.AffinityType
