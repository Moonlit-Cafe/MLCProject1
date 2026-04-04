extends BaseEventScene

#region Declarations
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
	
	for i in range(section_array.size(), 0):
		var cur_section = section_array[i]
		
		for j in range(1, randi_range(1,5)):
			cur_section.add_child(_generate_star())
			# TODO make star generation a thing
			return
		
		
		if section_array.size() <= i+1:
			var fwd_section = section_array[i+1]
			var f_star_maxi = fwd_section.get_children().size() - 1
			var c_star_maxi = cur_section.get_children().size()
			var split_indexes = [0, f_star_maxi]
			
			for split in range(0, c_star_maxi):
				split_indexes.append(randi_range(0, f_star_maxi))
			
			split_indexes.sort()
			
			for k in range(0, c_star_maxi):
				for l in range(split_indexes[i], split_indexes[i+1]):
					cur_section.get_children()[k].link_path(fwd_section.get_children()[l])
			
		
	
	
func _generate_star() -> Node:
	# TODO implement this
	# Make a star or something idk
	# prob needs it own class
	# should define what event should happen (steal from prog_scene)
	# star should be a button but have a sprite as a child
	# modulate the star based on event
	return null
#endregion
