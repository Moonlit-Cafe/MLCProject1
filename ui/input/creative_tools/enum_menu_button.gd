class_name EnumMenuButton extends MenuButton

#region Declarations
var _popup : PopupMenu
#endregion

#region Events
func _ready() -> void:
	_popup = get_popup()
	_popup.hide_on_checkable_item_selection = false

func init(enum_arr: Array, contains: Array[int]) -> void:
	var popup := get_popup()
	
	var idx : int = 0
	for key in enum_arr:
		popup.add_check_item(key, idx)
		if idx in contains:
			popup.set_item_checked(idx, true)
		idx += 1
	
	popup.id_pressed.connect(_on_item_pressed)

func get_data() -> Array[int]:
	var popup := get_popup()
	var checked_data : Array[int] = []
	for i in range(item_count):
		if popup.is_item_checked(i):
			checked_data.append(i)
	
	return checked_data
#endregion

#region Signal Callbacks
func _on_item_pressed(idx: int) -> void:
	var popup := get_popup()
	var is_checked := popup.is_item_checked(idx)
	popup.set_item_checked(idx, not is_checked)
#endregion
