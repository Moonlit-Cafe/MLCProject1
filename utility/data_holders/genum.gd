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
	MATERIAL,
	CONSUMABLE,
	SLOTTABLE,
	EQUIPMENT
}

## For declaring the rarity of an Item
enum ItemRarity {
	MUNDANE,
	ENCHANTED,
	ARCANE,
	MYSTIC,
	FORBIDDEN,
	ELDRITCH,
	COSMIC
}
