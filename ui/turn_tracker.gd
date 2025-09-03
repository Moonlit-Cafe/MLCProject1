extends Control

@export var turn_tracker : VBoxContainer
var turn_list : Array = []

# TODO: Rudimentary, but good start.

func generate_turns() -> void:
	if not turn_tracker:
		return
	
	for turn in turn_list:
		var turn_label := Label.new()
		turn_label.text = turn.name
		turn_tracker.add_child(turn_label)

func reorder_turns() -> void:
	var turn = turn_tracker.get_children().pop_front()
	turn_tracker.move_child(turn, turn_tracker.get_child_count())
