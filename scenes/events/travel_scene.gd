class_name TravelScene extends Control


var data : TravelData :
	set(new):
		data = new
		_populate_section()
		return
		
var layers = Array[Array[Node]]

## sets up zones on the planet given input data
func _populate_section() -> void:
	var layer_count = randi_range(data.min_layers, data.max_layers)
	var cur_width
	var cur_layer :Array[Node]
	layers = Array[layer_count - 1]
	var new_node
	for i in range(0, layer_count):
		cur_layer = layers[i]
		cur_width = randi_range(data.min_width, data.max_width)
		for j in range(0, cur_width):
			new_node = TravelNode.instantiate()
			cur_layers.append()
		
