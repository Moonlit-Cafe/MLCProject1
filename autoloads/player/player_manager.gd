extends Node

#region Declarations
var hp : int = 10 :
	set(value):
		if value <= 0:
			GameGlobalEvents.game_end.emit()
		else:
			hp = value
			GameGlobalEvents.hp_changed.emit()
var max_hp : int = 10
var mp : int = 10
var max_mp : int = 10
var haste : int = 200
var p_atk_mult : float = 1
var m_atk_mult : float = 1
var p_def : int = 0
var m_def : int = 0
var available_skills : Array[Action] = []
#endregion
