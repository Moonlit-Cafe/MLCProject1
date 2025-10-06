extends Node

#region Declarations
var hp : int = 10 :
	set(value):
		if value <= 0:
			GameGlobalEvents.game_end.emit()
		else:
			hp = value
			GameGlobalEvents.hp_changed.emit()
var mp : int = 10
var haste : int = 60
var available_skills : Array[Action] = []
#endregion
