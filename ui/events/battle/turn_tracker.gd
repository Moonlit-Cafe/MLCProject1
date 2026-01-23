class_name TurnTracker extends Control

@export var turn_labels : VBoxContainer
var turn_list : Array[TileEntity] = []

# TODO: Rudimentary, but good start.
func _ready() -> void:
	GameGlobalEvents.battle_removed.connect(remove_turn)

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
	
## Orders turns of all entities from highest Haste to lowest.
## this can sort a list that's halfway through looping
## eg a list that's normally [1,2,4,3]
## looped around to [4,3,1,2]
## Will sort around to [3,4,1,2]
func order_turns() -> void:
	var index
	
	for turn in turn_list:
		for compare_turn in turn_list:
			if compare_turn == turn:
				continue
			
			if compare_turn.haste <= turn.haste:
				index = turn_list.bsearch(turn)
				turn_list.pop_at(index)
				
				index = turn_list.bsearch(compare_turn)
				turn_list.insert(index, turn) # HACK this can get performance expensive with big lists
				break
				
		index = turn_list.bsearch(turn)
		turn_list.append(turn_list.pop_at(index))


func init_turns() -> void:
	order_turns()
	
	# TODO implement the rest of this
	# find the first biggest one
	# if its in the first spot, just return
	# else, split into two arrays,
