class_name Ability extends Node

@export var ac_name : String = "Action Name"
@export var ac_cost : float = 0.0

## How much the action does
# Units of movement, points of damage, points of health
@export var ac_value : float 

@export var ac_range : int = 0 ## default is self target range

@export var deciders : Array[Decider]

var ac_score : float = 0.0 :
	set(value) :
		ac_score = value
	get : return ac_score

func make_ac(_name,cost,value,range) -> void :
	ac_name = _name
	name = ac_name
	ac_cost = cost
	ac_value = value
	ac_range = range
	
