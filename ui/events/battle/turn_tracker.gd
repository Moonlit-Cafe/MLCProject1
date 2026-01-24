class_name TurnTracker extends Control

@export var turn_labels : VBoxContainer
var turn_list : Array[TileEntity] = []

#region Events
# TODO: Rudimentary, but good start.
func _ready() -> void:
	GameGlobalEvents.battle_removed.connect(remove_turn)
#endregion

#region Helpers

func generate_turns() -> void:
	if not turn_labels:
		return
	
	for turn in turn_list:
		var turn_label := Label.new()
		turn_label.text = turn.character.o_name
		turn_labels.add_child(turn_label)
	
	order_turns()
	# TODO other funcs?
	# should probably have a build turns
		# populate list with all turns

func remove_turn(actor: TileEntity) -> void:
	if not actor in turn_list:
		return
		
	# HACK potentially redundant code inside function?
	# could probably just use array.remove(array.bsearch(actor))
	# unless considerations are being made for multi-turn
	
	turn_list.erase(actor)
	for child in turn_labels.get_children():
		if child.text == actor.name:
			child.queue_free()
			return

func recycle_turn() -> void:
	var turn = turn_labels.get_children().pop_front()
	turn_labels.move_child(turn, turn_labels.get_child_count())
	
func validate_turn() -> void:
	pass
	# TODO implement this
	# just scans through the turn order
	# allows for one jump in haste
	
## Orders turns of all entities from highest Haste to lowest, 
## while also preserving the current turn
## eg: a list that's normally [1,2,4,3]
## looped around to [4,3,1,2]
## Will sort around to [3,4,1,2]
func order_turns() -> void:
	var new_list = []
	
	if turn_list == []:
		return
	# if turn_list_ordered:
		# return
	
	new_list = _turn_sublist(turn_list[0])
	
	var second_list = []
	while turn_list != []:
		
		
	new_list.append_array(second_list)
	
	self.turn_list = new_list

func init_turns() -> void:
	order_turns()
	
	# TODO implement the rest of this
	# find the first biggest one
	# if its in the first spot, just return
	# else, split into two arrays,


func _turn_sublist(cur_turn) -> Array[TileEntity]:
	var new_list = []
	var cur_next = cur_turn.haste
	
	while turn_list != []:
		for turn in turn_list:
			if turn.haste == cur_turn.haste:
				turn_list.pop_at(turn_list.bsearch(turn))
				new_list.append(turn)
				
			elif turn.haste < cur_next:
				cur_next = turn.haste
			
		if cur_next == cur_turn.haste:
			break
	
	return new_list
#endregion
