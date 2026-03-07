class_name TurnTracker extends Control

signal new_turn(cur_is_player)

@export var turn_labels : VBoxContainer
var turn_list : Array[TileEntity] = []

var player_turn : bool = false

#region Events
# TODO: Rudimentary, but good start.
func _ready() -> void:
	GameGlobalEvents.battle_removed.connect(remove_turn)
	
## Orders turns of all entities from highest Haste to lowest, 
## while also preserving the current turn
## eg: a list that's normally [1,2,4,3]
## looped around to [4,3,1,2]
## Will sort around to [3,4,1,2]
func reorder_turns() -> void:
	if turn_list == []:
		return
	
	if validate_turns():
		return
	
	var list_header = turn_list[0]
	
	turn_list.sort_custom(_compare_haste)
	
	
	
	# HACK potential computation pain point
	# dont know if its faster to do this or rearrange slices of the array
	# mostly depends on slice comp time
	# bsearch would make this basically run at o(logn)
	# this just runs at o(n)
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
	

func remove_turn(actor: TileEntity) -> void:
	if not actor in turn_list:
		return
		
	# HACK potentially redundant code inside function?
	# could probably just use array.remove(array.bsearch(actor))
	# unless considerations are being made for multi-turn
	
	turn_list.erase(actor)
	for child in turn_labels.get_children():
		if child.text == actor.character.o_name:
			child.queue_free()
			return

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

#func _turn_sublist(cur_turn) -> Array[TileEntity]:
	#var new_list = []
	#var cur_next = cur_turn.haste
	#
	#while turn_list != []:
		#for turn in turn_list:
			#if turn.haste == cur_turn.haste:
				#turn_list.pop_at(turn_list.bsearch(turn))
				#new_list.append(turn)
				#
			#elif turn.haste < cur_next:
				#cur_next = turn.haste
			#
		#if cur_next == cur_turn.haste:
			#break
	#
	#return new_list
	
func _compare_haste(a, b) -> bool:
	if a.haste < b.haste:
		return true
	return false
#endregion
