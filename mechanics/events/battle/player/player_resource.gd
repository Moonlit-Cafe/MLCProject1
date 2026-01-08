class_name PlayerCharacter extends CharacterResource


#region Declarations
@export var haste : int = 10 ## How fast the enemy is
## The base stats of the enemy
@export var player_stats : Dictionary[StringName, float] = {
	&"hp" : 10.,
	&"p_def": 0.,
	&"m_def": 0.,
	&"p_atk": 1.,
	&"m_atk": 0.,
}
# TODO: Later, need to standardize the animation scheme for the enemies
#endregion

#region Events
func init() -> void:
	super()
	_build_stats(player_stats)
#endregion
