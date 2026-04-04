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
		var cur = section_array[i]
		
		for j in range(1, randi_range(1,5)):
			cur.add_child(_generate_star())
			# TODO implement this
			return
		
		if section_array.size() <= i+1:
			# TYLERCOM also needs to attempt to connect to previous column (if possible)
			var prev = section_array[i+1]
			
		
	
	
func _generate_star() -> Node:
	# TODO implement this
	# Make a star or something idk
	# prob needs it own class
	return null
#endregion
