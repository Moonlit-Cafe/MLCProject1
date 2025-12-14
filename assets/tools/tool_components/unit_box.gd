class_name UnitBox extends VBoxContainer

@export var unit_name_label : Label
@export var unit_name : String = "" :
	set(value) :
		unit_name = value
		unit_name_label.text = value
	get : return unit_name
