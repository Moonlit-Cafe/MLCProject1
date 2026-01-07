class_name PlayerCharacter extends Resource


#region Declarations
@export var o_name : StringName ## The name of the 
@export var haste : int = 10 ## How fast the enemy is
## The base stats of the enemy
@export var stats : Dictionary[StringName, int] = {
	&"hp" : 10,
	&"p_def": 0,
	&"m_def": 0,
	&"p_atk": 1,
	&"m_atk": 0,
}
## The rate at which the enemy's stats scale with difficulty
@export var stats_scaling : Dictionary[StringName, float] = {
	&"hp" : 1.0,
	&"p_def": 1.0,
	&"m_def": 1.0,
	&"p_atk": 1.0,
	&"m_atk": 1.0,
}
# TODO: Later, need to standardize the animation scheme for the enemies
@export var frames : SpriteFrames ## The visual animations of the player
#endregion
