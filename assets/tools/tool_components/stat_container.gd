class_name StatsLabel extends HBoxContainer

@export var name_label = Label
@export var amt_label = Label

@export var stat_name : String = "" :
	set(value) :
		stat_name = value
		if name_label.text != "" :
			name_label.text = value
	get : return stat_name
@export var stat_amt : float = 0.0 :
	set(value) :
		stat_amt = value
		if amt_label.text != "" :
			amt_label.text = str(value)
	get : return stat_amt


func _ready() -> void:
	#set up our stats label #/#
	amt_label.text = "%s / %s" % [str(stat_amt), str(stat_amt)]
