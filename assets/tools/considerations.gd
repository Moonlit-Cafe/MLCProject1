extends Control
#region Exports
@export var p_health : float = 0.0
@export var p_mana : float = 0.0
@export var p_movement : float = 0.0
@export var e_health : float = 0.0
@export var e_mana : float = 0.0
@export var e_movement : float = 0.0
#endregion

var characters:Dictionary = {}


func _ready() -> void:
	characters["player"] = [p_health,p_mana,p_movement]
	characters["enemy"] = [e_health,e_mana,e_movement]
