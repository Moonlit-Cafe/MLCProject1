extends BaseEventScene

#region Declarations
@export var travel_button : PackedScene
@export var scenes : Array[Resource]

@onready var sections = $SectionContainer 
#endregion

#region Events
func _ready() -> void:
	_generate_sections()
	_generate_stars()
#endregion


#region Helpers
func _generate_sections() -> void:
	var section_count = randi_range(5,11)
	var new_section
	
	for i in range(0, section_count):
		new_section = VBoxContainer.new()
		sections.add_child(new_section)

func _generate_stars() -> void:
	var section_array = sections.get_children()
	
	# TODO actually give a sprite to buttons
	# TODO visually show connections between stars
	for column_index in range(section_array.size()-1, 0, -1):
		var cur_section = section_array[column_index]
		
		for i in range(0, randi_range(1,5)):
			cur_section.add_child(_generate_star())
		
		
		if section_array.size() > column_index-1:
			var fwd_section = section_array[column_index]
			var far_star_max_index = fwd_section.get_children().size() - 1
			var cur_star_max_index = cur_section.get_children().size()
			var split_indexes = [0, far_star_max_index]
			
			for split in range(0, cur_star_max_index):
				split_indexes.append(randi_range(0, far_star_max_index))
			
			split_indexes.sort()
			
			for star_i in range(0, cur_star_max_index):
				for l in range(split_indexes[star_i-1], split_indexes[star_i]):
					# TODO Tyler dont guarantee that the left or right end is going to be connected (conditional)
					cur_section.get_children()[star_i].link_path(fwd_section.get_children()[l])


func _generate_star() -> Button:
	var cur_button = travel_button.instantiate()
	cur_button.init(scenes)
	return cur_button
#endregion
