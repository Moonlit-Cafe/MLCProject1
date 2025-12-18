extends Node

#region Declarations
var hp : int = 10 :
	set(value):
		if value <= 0:
			GameGlobalEvents.game_end.emit()
		else:
			hp = value
			GameGlobalEvents.hp_changed.emit()
var equipped_items : Array[EquippableItem]
var stats : Dictionary[Genum.StatType, int] = {
	Genum.StatType.HEALTH: 10,
	Genum.StatType.AETHER: 10,
	Genum.StatType.ATTACK: 1,
	Genum.StatType.ATTACK_POWER: 100,
	Genum.StatType.MAGIC: 1,
	Genum.StatType.MAGIC_POWER: 100,
	Genum.StatType.HASTE: 200,
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
var position : Vector2i = Vector2i.ZERO
#endregion

#region Publics
func get_usables() -> Array[ItemNode]:
	var inventory : CanvasLayer = get_tree().get_first_node_in_group(&"inventory")
	var usables : Array[ItemNode] = inventory.get_usables()
	return usables

func regen_combat_stats() -> void:
	var stats_to_modify : Dictionary[Genum.StatType, Array]
	for item in equipped_items:
		for stat in item.stats:
			if not stat.stat in stats_to_modify:
				stats_to_modify.set(stat.stat, [stat.modify_amount])
				continue
			
			stats_to_modify.get(stat.stat).append(stat.modify_amount)
	
	stats_to_modify = _check_item_sets(stats_to_modify)
	combat_stats = stats
	for stat in stats_to_modify.keys():
		for modifier in stats_to_modify.get(stat):
			combat_stats.set(stat, combat_stats.get(stat) + modifier)
	print(combat_stats)
#endregion

#region Helpers
#TODO: Definitely need to come back and work on this more, but good enough for prototype
func _check_item_sets(stats_mod: Dictionary[Genum.StatType, Array]) -> Dictionary[Genum.StatType, Array]:
	var sets : Dictionary[StringName, int] = {}
	for item in equipped_items:
		if not item.item_set:
			continue
		
		if not item.item_set in sets.keys():
			sets.set(item.item_set, 1)
		else:
			sets.set(item.item_set, sets.get(item.item_set) + 1)
	
	for i_set in sets.keys():
		var item_set : ItemSet
		for ref_set in SkillManager.set_compendium:
			if ref_set.set_id == i_set:
				item_set = ref_set
		
		if not item_set:
			continue
		
		for set_i in item_set.set_bonuses.keys():
			if set_i <= sets.get(i_set):
				for bonus in item_set.set_bonuses.get(set_i):
					stats_mod.get(bonus.stat).append(bonus.modify_amount)
	
	print(stats_mod)
	return stats_mod
#endregion
