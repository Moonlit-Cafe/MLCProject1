extends Node

#region Declarations
@export var character_data : PlayerCharacter

var hp : int = 10 :
	set(value):
		if value <= 0:
			GameGlobalEvents.game_end.emit()
		else:
			hp = value
			CombatManager.hp_changed.emit()
var equipped_items : Array[EquippableItem]
var stats : Dictionary[Genum.StatType, int] = {
	Genum.StatType.HEALTH: 10,
	Genum.StatType.AETHER: 10,
	Genum.StatType.ATTACK: 1,
	Genum.StatType.ATTACK_POWER: 100,
	Genum.StatType.MAGIC: 1,
	Genum.StatType.MAGIC_POWER: 100,
	Genum.StatType.HASTE: 200,
	Genum.StatType.SPEED: 3,
	Genum.StatType.BARRIER: 0,
	Genum.StatType.STAMINA: 10,
	Genum.StatType.CRIT_RATE: 0,
	Genum.StatType.CRIT_DMG: 100,
	Genum.StatType.EVASION: 0,
	Genum.StatType.ATK_DMG_UP: 0,
	Genum.StatType.SPELL_DMG_UP: 0,
	Genum.StatType.ATH_ON_HIT: 0
}
var combat_stats := stats
var available_skills : Array[Action] = []
var available_items : Array[Usable] = []
var position : Vector2i = Vector2i.ZERO
var occupied_tile : BattleTile
var entity_ref : TilePlayer

var set_bonuses : PackedByteArray
#endregion

#region Events

## Initializes the character data based on the initial stats
# TODO: Should be affected by saves later on.
func init_character_data() -> void:
	var new_data := PlayerCharacter.new()
	for data_piece in stats.keys():
		if data_piece in new_data.player_stats.keys():
			continue
		elif data_piece == Genum.StatType.HASTE:
			continue
		new_data.set(data_piece, stats.get(data_piece))
	
	new_data.haste = stats.get(Genum.StatType.HASTE)
	new_data.init()
	character_data = new_data
	
	

## Gets the player's available usable items from within the inventory
func get_usables() -> Array[Usable]:
	var inventory : CanvasLayer = get_tree().get_first_node_in_group(&"inventory")
	if not inventory:
		return []
	var usables : Array[Usable] = inventory.get_usables()
	return usables

## Regenerates the combat stats, typically because they've been changed
func regen_combat_stats() -> void:
	_update_combat_stats(_get_equip_stats())
	
func _update_combat_stats(incoming_stats):
	for stat in incoming_stats.keys():
		for modifier in incoming_stats.get(stat):
			combat_stats.set(stat, combat_stats.get(stat) + modifier)
	
	
	
func _get_equip_stats() -> Dictionary[Genum.StatType, Array]:
	var stats_to_modify : Dictionary[Genum.StatType, Array]
	for item in equipped_items:
		for stat in item.stats:
			if not stat.stat in stats_to_modify:
				stats_to_modify.set(stat.stat, [stat.modify_amount])
				continue
			
			stats_to_modify.get(stat.stat).append(stat.modify_amount)
	
	return stats_to_modify
#endregion

#region Helpers
## Compares applied bonuses to incoming bonuses.
## Based on PackedByteArray passed from PlayerHUD


func update_sets(incoming_bonuses:PackedByteArray) -> void:
	if not set_bonuses:
		set_bonuses = PackedByteArray()
		set_bonuses.resize(incoming_bonuses.size())
	
	for i in set_bonuses:
		if set_bonuses[i] != incoming_bonuses[i]:
			_update_bonus(i, incoming_bonuses[i])
	
	set_bonuses = incoming_bonuses.duplicate()
	
func _update_bonus(index:int, value:int) -> void:
	var bonus
	match index:
		Genum.EquipSet.BOMBA:
			# TODO give the player a firebolt here
			# should mostly be wired, just waiting for the last pieces to connect
			# bonus = ActionManager.a_data[&"Firebolt"]
			bonus = {Genum.StatType.HEALTH: 30}
			
			
	if bonus is Action:
		if value:
			# PlayerManager.available_skills.append(value)
			pass
		else:
			# var i = PlayerManager.available_skills.bsearch(bonus)
			# PlayerManager.available_skills.remove_at(i)
			pass
	elif bonus is Dictionary:
		var key = bonus.keys()[0]
		if value:
			combat_stats.set(key, combat_stats.get(key) + bonus[key])
		else:
			combat_stats.set(key, combat_stats.get(key) - 	bonus[key])

	else:
		push_warning("No bonus_type selected for set_id: " + str(set_bonuses[index]))
		return
	
	
	# PlayerManager.UPDATE_THE_ACTION_MENU_PLS()
	
## Used to check if an Item Set prerequisite is met, if so then boosts stats.
#TODO: Definitely need to come back and work on this more, but good enough for prototype
#func _check_item_sets(stats_mod: Dictionary[Genum.StatType, Array]) -> Dictionary[Genum.StatType, Array]:
	#var sets : Dictionary[StringName, int] = {}
	#for item in equipped_items:
	#	if not item.item_set:
	#		continue
	#	
	#	if not item.item_set in sets.keys():
	#		sets.set(item.item_set, 1)
	#	else:
	#		sets.set(item.item_set, sets.get(item.item_set) + 1)
	#
	#for i_set in sets.keys():
	#	var item_set : ItemSet
	#	for ref_set in CombatManager.skill_manager.set_compendium:
	#		if ref_set.set_id == i_set:
	#			item_set = ref_set
	#	
	#	if not item_set:
	#		continue
	#	
	#	for set_i in item_set.set_bonuses.keys():
	#		if set_i <= sets.get(i_set):
	#			for bonus in item_set.set_bonuses.get(set_i):
	#				stats_mod.get(bonus.stat).append(bonus.modify_amount)
	
	#return stats_mod
#endregion
