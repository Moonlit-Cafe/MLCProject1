extends BaseEventScene

#region Declarations
@export var travel_button : PackedScene
@export var scenes : Array[Resource]

var last_node : TravelButton
@onready var sections = $SectionContainer 
#endregion

#region Events
func _ready() -> void:
	_generate_sections()
	_generate_stars()
	check_buttons()
#endregion


#region Helpers
func _generate_sections() -> void:
	var section_count = randi_range(5,11)
	var new_section
	
	for i in range(0, section_count):
		new_section = VBoxContainer.new()
		sections.add_child(new_section)
		new_section.alignment = VBoxContainer.ALIGNMENT_CENTER

	
func _generate_stars() -> void:
	var section_array = sections.get_children()
	
	for column_index in range(section_array.size()-1, -1, -1):
		var cur_section = section_array[column_index]
		var cap
		const min_cap = 2
		const max_cap = 5
		
		if column_index == 0:
			cap = min_cap
		elif  column_index == section_array.size()-1:
			cap = min_cap
		else:
			cap = randi_range(min_cap, max_cap)
		
		for i in range(min_cap - 1, cap):
			cur_section.add_child(_generate_star())
		
		if section_array.size() > column_index + 1:
			var fwd_section = section_array[column_index + 1]
			var far_star_max_index = fwd_section.get_children().size() - 1
			var cur_star_count = cur_section.get_children().size()
			var split_indexes = [0, far_star_max_index]
			
			for split in range(1, cur_star_count):
				split_indexes.append(randi_range(0, far_star_max_index))
			
			split_indexes.sort()
			
			for star_i in range(0, cur_star_count):
				var t = range(split_indexes[star_i], split_indexes[star_i+1])
				if split_indexes[star_i] == split_indexes[star_i+1]:
					t = [split_indexes[star_i]]
				
				for l in t:
					# PLANNED Tyler dont guarantee that the left or right end is going to be connected (conditional)
					# conditions that all nodes have to have someone be their others
					cur_section.get_children()[star_i].link_path(fwd_section.get_children()[l])
				

	last_node = section_array[0].get_child(0)


func _generate_star() -> Button:
	var cur_button = travel_button.instantiate()
	cur_button.init(scenes)
	return cur_button
#endregion

func check_buttons() -> void:
	for section in sections.get_children():
		for button in section.get_children():
			button.disabled = true
			
		for next in last_node.others:
			next.disabled = false
			
