class_name UnitBox extends VBoxContainer

@export var unit_name_label : Label
@export var unit_name : String = "" :
	set(value) :
		unit_name = value
		if unit_name_label != null :
			unit_name_label.text = value
	get : return unit_name

@export var health_box : StatsLabel
@export var mana_box : StatsLabel
@export var movement_box : StatsLabel

var health : float
var mana : float
var movement : float

func _ready() -> void:
	health = health_box.stat_amt
	mana = mana_box.stat_amt
	movement = movement_box.stat_amt
	
	
func update() -> void :
	health_box.stat_amt = health
	mana_box.stat_amt = mana
	movement_box.stat_amt = movement
