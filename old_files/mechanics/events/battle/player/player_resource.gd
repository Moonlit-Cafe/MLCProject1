class_name PlayerCharacter extends CharacterResource


#region Declarations
@export var haste : int = 10 ## How fast the player is
## The base stats of the player
@export var player_stats : Dictionary[Genum.StatType, float] = {
	Genum.StatType.HEALTH: 10.,
	Genum.StatType.STAMINA: 0.,
	Genum.StatType.BARRIER: 0.,
	Genum.StatType.ATTACK: 1.,
	Genum.StatType.MAGIC: 0.,
}
#endregion

#region Events
func init() -> void:
	super()
	_build_stats(player_stats)
#endregion
