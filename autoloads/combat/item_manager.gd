## Autoload in charge of items' actions in combat.
class_name ItemManager extends Node

#region Declarations
@export_file("*.json") var usable_file : String ## The filepath for where all the usable items are located.
@export_file("*.json") var action_shapes : String
@export var set_compendium : Array[ItemSet]

var all_usables : Array[Usable]
#endregion

#region Events
func _ready() -> void:
	_define_usables()
	
	print("Initialized: ItemManager")

## Generates the usable items and attaches all of their relevant data.
func _define_usables() -> void:
	if not usable_file:
		push_warning("@ItemManager: There is no path to usables.json")
		return
	
	var file = FileAccess.open(usable_file, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if not data:
		push_warning("@ItemManager: Something wrong with file format")
		return
		
	for usable in data.keys():
		var us := Usable.new()
		us.us_id = usable
		if attach_data(us, data.get(usable)):
			continue
			
		all_usables.append(us)

## Gets a particular usable based on [param given_id]
func get_usable(given_id:String) -> Usable:
	for usable:Usable in all_usables:
		if usable.us_id == given_id:
			return usable
			
	push_warning("@ItemManager: usable with id " + given_id + " not found.")

	return null
#endregion


#region Helpers
func attach_data(usable:Usable, us_data):
	usable.us_id = usable.us_id
	usable.us_name = us_data.get("name")
	var shape = CombatManager.skill_manager.find_shape(us_data.get("shape"))
	if not shape:
		push_warning("@ItemManager: There is no shape of id: %s" % us_data.get("shape"))
		return
	usable.shape = CombatManager.skill_manager.find_shape(us_data.get("shape"))
	usable.value = us_data.get("value")
	usable.combat_ok = us_data.get("combat_ok")
#endregion
