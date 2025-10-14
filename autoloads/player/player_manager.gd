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
#endregion

#region Publics
func regen_combat_stats() -> void:
	var stats_to_modify : Dictionary[Genum.StatType, Array]
	for item in equipped_items:
		for stat in item.stats:
			if not stat.stat in stats_to_modify:
				stats_to_modify.set(stat.stat, [stat.modify_amount])
				continue
			
			stats_to_modify.get(stat.stat).append(stat.modify_amount)
	
	combat_stats = stats
	for stat in stats_to_modify.keys():
		for modifier in stats_to_modify.get(stat):
			combat_stats.set(stat, combat_stats.get(stat) + modifier)
	
	print(combat_stats)
#endregion
