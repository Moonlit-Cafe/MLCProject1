class_name MoveBox extends ActionBox

@export var nb : Button

func _ready() -> void:
	super._ready()
	nb.text = "- %s" % name_label_text

func _on_neg_action_pressed() -> void :
	
	pass # handle negative action
