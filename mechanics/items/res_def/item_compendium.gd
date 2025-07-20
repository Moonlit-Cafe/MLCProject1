## Holds the data for all existing items in the game.
class_name ItemCompendium extends Resource

@export var material_compendium : Array[MaterialItem]
@export var usable_compendium : Array[UsableItem]
@export var equip_compendium : Array[EquippableItem]
@export var weapon_compendium : Array[WeaponItem]
@export var powercore_compendium : Array[PowerCoreItem]
var item_reference : Array[Item]

func init() -> void:
	for item in material_compendium:
		item_reference.append(item)
	material_compendium.clear()
	
	for item in usable_compendium:
		item_reference.append(item)
	usable_compendium.clear()
	
	for item in equip_compendium:
		item_reference.append(item)
	equip_compendium.clear()
	
	for item in weapon_compendium:
		item_reference.append(item)
	weapon_compendium.clear()
	
	for item in powercore_compendium:
		item_reference.append(item)
	powercore_compendium.clear()
	
	for i in range(item_reference.size()):
		if i < item_reference.size() - 2:
			if item_reference.get(i).id < item_reference.get(i).id:
				continue
			else:
				var item_1 = item_reference.get(i)
				var item_2 = item_reference.get(i + 1)
				item_reference.set(i, item_2)
				item_reference.set(i + 1, item_1)
		
