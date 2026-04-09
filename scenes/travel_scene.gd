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
	
	# FIXME As is, map generation still broken.
	# Specifically, some columns dont get iterated on
	# TODO actually give a sprite to buttons
	# TODO visually show connections between stars
	# TYLERCOM written 4/8
	for i in range(section_array.size()-1, 0, -1):
		var cur_section = section_array[i]
		
		for j in range(1, randi_range(1,5)):
			cur_section.add_child(_generate_star())
		
		
		if section_array.size() <= i:
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


func _generate_star() -> Button:
	var cur_button = travel_button.instantiate()
	cur_button.init(scenes)
	return cur_button
#endregion
