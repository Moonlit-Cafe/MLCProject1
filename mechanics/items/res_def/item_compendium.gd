## Holds the data for all existing items in the game.
class_name ItemCompendium extends Resource

@export var material_compendium : Array[ItemMaterial]
@export var usable_compendium : Array ## TODO: Create UsableItem resource
@export var equip_compendium : Array[EquippableItem]
@export var weapon_compendium : Array[Weapon]
