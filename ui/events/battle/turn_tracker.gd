class_name TurnTracker extends Control

signal new_turn(cur_is_player)

@export var turn_labels : VBoxContainer
var turn_list : Array[TileEntity] = []

var player_turn : bool = false

#region Events
func _ready() -> void:
	GameGlobal.events.battle_removed.connect(remove_turns)
	print(GameGlobal.events.battle_removed.get_connections())
	
func reorder_turns() -> void:
	if turn_list == []:
		return
	
	if validate_turns():
		return
	
	var list_header = turn_list[0]
	
	turn_list.sort_custom(_compare_haste)
	
	while turn_list[0] != list_header:
		recycle_turn()
		
#endregion

#region Helpers

func generate_turns() -> void:
	if not turn_labels:
		return
	
	for turn in turn_list:
		var turn_label := Label.new()
		turn_label.text = turn.character.o_name
		turn_labels.add_child(turn_label)
	
	turn_list.sort_custom(_compare_haste)
	
	new_turn.emit(turn_labels.get_children()[0].text == "Player")
	

func remove_turns(actor: TileEntity) -> void:
	if not actor in turn_list:
		return
	
	turn_list.erase(actor)
		
	for child in turn_labels.get_children():
		if child.text == actor.character.o_name:
			child.queue_free()
			return

## Moves current turn to the end of the queue
func recycle_turn() -> void:
	var turn = turn_labels.get_children().pop_front()
	turn_labels.move_child(turn, turn_labels.get_child_count())
	new_turn.emit(turn_labels.get_children()[0].text == "Player")


func validate_turns() -> bool:
	if turn_list == []:
		return true
	
	var cur_haste = turn_list[0].haste
	var looped = false
	
	for turn in turn_list:
		if turn.haste > cur_haste:
			if looped:
				return false
			else:
				looped = true
				continue
	
	return true

	
func _compare_haste(a, b) -> bool:
	if a.haste < b.haste:
		return true
	return false
#endregion
