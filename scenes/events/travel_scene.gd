class_name TravelScene extends Control

#region Declarations
var new_travel_node : PackedScene = preload("res://mechanics/battle/travel/travel_node.tscn")

var data : TravelData :
	set(new):
		if not new:
			return
			
		data = new
		_populate_section()
		
var layers: Array[Array]
var cur_node : TravelNode = null
		
#endregion

#region Events
## sets up zones on the planet given input data
func _populate_section() -> void:
	var layer_count : int

	layer_count  = randi_range(data.min_layers, data.max_layers)
	_disperse_nodes(layer_count)
	_link_nodes(layer_count)
	highlight_selectables()

## Displaces and organizes positions of travel nodes
func _disperse_nodes(layer_count) -> void:
	var cur_layer : Array
	var cur_width : int
	var new_node : TravelNode
	
	const X_GAP : int = 100
	const X_INIT : int = 50
	const Y_GAP : int = 100
	const Y_INIT : int = 50
	
	layers.resize(layer_count)
	
	for i in range(0, layer_count):
		cur_layer = layers[i]
		cur_width = randi_range(data.min_width, data.max_width)
		if i == 0:
			cur_width = 1
		for j in range(0, cur_width):
			new_node = new_travel_node.instantiate()
			cur_layer.append(new_node)
			new_node.position = Vector2(X_INIT + X_GAP * i, Y_INIT + Y_GAP * j)
			add_child(new_node)
			new_node.name = 'Node %d, %d' % [i, j]


## Assign paths for node-to-node travel
func _link_nodes(layer_count: int) -> void:
	for layer_index in range(0, layer_count - 1):
		var cur_layer = layers[layer_index]
		var cur_width : int = cur_layer.size()
		var l_index : int = 0
		
		var next_layer : Array = layers[layer_index+1]
		var next_width : int = next_layer.size()
		var r_index : int = next_width
		
		for node_index in range(0, cur_width):
			
			r_index = randi_range(l_index+1, next_width)
			
			if node_index == cur_width-1 or l_index == next_width:
				r_index = next_width
				
			var new_connections = next_layer.slice(l_index, r_index)
			# HACK replace this with the debug notification system
			# print('%s / %s, %s / %s, %s - %s // %s' % [layer_index+1, layer_count, node_index+1, cur_width, l_index, r_index, next_width])
			cur_layer[node_index].links = new_connections
			
			l_index = randi_range(l_index, next_width-1) 
	

## visually change tiles to indicate availability of travel
func highlight_selectables() -> void:
	for column : Array in layers:
		for node : TravelNode in column:
			node.modulate = Color.DARK_GRAY
			node.selectable = false

	if not cur_node:
		cur_node = layers[0][0]
	
	cur_node.modulate = Color.BLUE
	for child in cur_node.links:
		child.modulate = Color.WHITE
		child.selectable = true
		

## Updates cur_node, or clears if the new one is the same as the pre-existing one.
#HACK Currently not a setter since im not sure how godot supports signals to custom setters
# It IS possible though, at least in 4.3? https://github.com/godotengine/godot/issues/92782
func update_node(new: TravelNode):
		if cur_node == new:
			cur_node = null
			return
		cur_node = new
#endregion

#region Processes
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("mouse_action"):
		if not cur_node:
			return
		cur_node.clicked()
#endregion
