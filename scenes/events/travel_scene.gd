class_name TravelScene extends Control

#region Declarations
var data : TravelData :
	set(new):
		if not new:
			return
			
		data = new
		_populate_section()
		
var layers: Array[Array]

var new_travel_node : PackedScene = preload("res://mechanics/battle/travel/travel_node.tscn")
#endregion

#region Events
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
		for j in range(0, cur_width):
			new_node = new_travel_node.instantiate()
			cur_layer.append(new_node)
			new_node.position = Vector2(X_INIT + X_GAP * i, Y_INIT + Y_GAP * j)
			add_child(new_node)
			new_node.name = 'Node %d, %d' % [i, j]

## sets up zones on the planet given input data
func _populate_section() -> void:
	var layer_count : int

	layer_count  = randi_range(data.min_layers, data.max_layers)
	_disperse_nodes(layer_count)
	_link_nodes(layer_count)
	

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
			print('%s / %s, %s / %s, %s - %s // %s' % [layer_index+1, layer_count, node_index+1, cur_width, l_index, r_index, next_width])
			if new_connections.size() == 0:
				print('fuck')
			cur_layer[node_index].connections = new_connections
			
			l_index = randi_range(l_index, next_width-1) 
	
	# TYLER remember current travel layer
		# modulate current layer node to yellow
		# modulate all selectables to blue
#endregion
