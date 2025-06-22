## This is where all the game's common Enums are listed.
class_name Genum

## The Enum used for Audio Buses.
enum BusID {
	MASTER,
	OST,
	SFX,
	UI,
	AMBIENT
}

## The Enum to attach to items to declare how that item is allowed to interact.
enum ItemTags {
	MATERIAL, ## Used for crafting
	CONSUMABLE, ## Is consumed on use
	SLOTTABLE, ## Can be slotted into equips
	EQUIPMENT ## Can be equipped
}

## For declaring the rarity of an Item
enum ItemTier {
	MUNDANE, ## Tier 1, lvl 1-10
	ENCHANTED, ## Tier 2, lvl 11 - 20
	ARCANE, ## Tier 3, lvl 21 - 30
	MYSTIC, ## Tier 4, lvl 31 - 40
	FORBIDDEN, ## Tier 5, lvl 41 - 50
	ELDRITCH, ## Tier 6, lvl 51 - 60
	COSMIC ## Tier 7, lvl 61 - 70
}
