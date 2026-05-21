extends BaseEventScene


#region Declarations
@export var travel_button : PackedScene
@export var scenes : Array[Resource]

var current_scene
@export var scene_holder : Node
@export var section_container : Node
var last_node : TravelButton :
	set(in_node):
		in_node.disable_children(false)
		in_node.disabled = true
		
		if last_node:
			last_node.disable_children(true)
			last_node.disabled = true
			adjust_scene()
		
		last_node = in_node

@onready var container = $SectionContainer
@onready var sections
#endregion


#region Events
func _ready() -> void:
	SceneManager.travel_scene = self
	_build_travel()
	
	

#endregion


#region Helpers
func _build_travel():
	_generate_sections()
	_generate_stars()
	check_buttons()

func adjust_scene():
	const SCENE_SCROLL_AMT = 16
	$SectionContainer.position.x -= SCENE_SCROLL_AMT
	
func _generate_sections() -> void:
	var section_count = randi_range(5,11)
	var new_section
	
	for i in range(0, section_count):
		new_section = VBoxContainer.new()
		container.add_child(new_section)
		new_section.alignment = VBoxContainer.ALIGNMENT_CENTER


func _generate_stars() -> void:
	sections = container.get_children()
	const min_cap = 2
	const max_cap = 5
	
	for column_index in range(sections.size()-1, -1, -1):
		var cur_cap
		if column_index in [0, sections.size()-1] :
			cur_cap = min_cap
		else:
			cur_cap = randi_range(min_cap, max_cap)
		
		var cur_section = sections[column_index]
		for i in range(min_cap - 1, cur_cap):
			cur_section.add_child(_generate_star())
		
		if sections.size()-1 > column_index:
			var split_indexes = _split_fwd_indexes(column_index)
			_link_forward_column(column_index, split_indexes)
		
	last_node = sections[0].get_child(0)
		
func _split_fwd_indexes(column_index) -> Array:
	var cur_section = sections[column_index]
	var fwd_section = sections[column_index + 1]
	var far_star_max_index = fwd_section.get_children().size() - 1
	var cur_star_count = cur_section.get_children().size()
	var split_indexes = [0, far_star_max_index]
	
	for split in range(1, cur_star_count):
		split_indexes.append(randi_range(0, far_star_max_index))
	split_indexes.sort()
		
	return split_indexes
		
		
func _link_forward_column(column_index, split_indexes):
	var cur_section = sections[column_index]
	var cur_star_count = cur_section.get_children().size()
	var fwd_section = sections[column_index+1]
	
	for star_i in range(0, cur_star_count):
		var fwd_split = split_indexes[star_i+1]
		var fwd_indices = range(split_indexes[star_i], fwd_split)
		var cur : TravelButton = cur_section.get_child(star_i)
		
		fwd_indices.append(fwd_split)
		fwd_indices.sort()
		
		for fwd_index in fwd_indices:
			const LEFT_LINK_CHANCE = .5
			const RIGHT_LINK_CHANCE = .6666
			var fwd = fwd_section.get_child(fwd_index)
			if fwd_indices.size() > 1:
				if star_i > 0 and fwd_index != fwd_indices[0]:
					if fwd in cur_section.get_child(star_i-1).others:
						if randf_range(0, 1) < LEFT_LINK_CHANCE:
							continue
				if star_i+1 < cur_star_count: 
					if fwd_index == fwd_indices[-1]:
						if cur.others != []:
							if randf_range(0,1) < RIGHT_LINK_CHANCE:
								continue

			cur.link_path(fwd)
	
func return_to_map():
	container.show()
	scene_holder.get_child(0).queue_free()

func check_buttons() -> void:
	for section in sections:
		for button in section.get_children():
			button.disabled = true
			
		for next in last_node.others:
			next.disabled = false


func _generate_star() -> Button:
	var cur_button = travel_button.instantiate()
	cur_button.init(scenes)
	cur_button.travel_scene = self
	cur_button.next_scene.connect(_on_button_press)
	return cur_button
#endregion


#region Signal Callbacks
func _on_button_press(incoming:TravelButton):
	var new_scene : BaseEventScene = incoming.node_data.scene.instantiate()
	if current_scene:
		scene_holder.remove_child(current_scene)
		scene_holder.add_child(new_scene)
		current_scene.queue_free()
		current_scene = new_scene
	else:
		scene_holder.add_child(new_scene)
		current_scene = new_scene
	
	container.hide()
#endregion
