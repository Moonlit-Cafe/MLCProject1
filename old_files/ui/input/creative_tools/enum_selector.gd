class_name EnumSelectorButton extends MenuButton

#region Declarations
var _popup : PopupMenu
#endregion

#region Events
func _ready() -> void:
	_popup = get_popup()
	_popup.hide_on_checkable_item_selection = false

func init(enum_arr: Array, value: int) -> void:
	var popup = get_popup()
	var idx : int = 0
	for key in enum_arr:
		popup.add_check_item(key, idx)
		if idx == value:
			popup.set_item_checked(idx, true)
		idx += 1
	
	popup.id_pressed.connect(_on_item_pressed)

func get_data() -> int:
	var chosen : int = -1
	for i in range(item_count):
		if _popup.is_item_checked(i):
			chosen = i
	
	return chosen
#endregion

#region Signal Callbacks
func _on_item_pressed(idx: int) -> void:
	for i in range(item_count):
		if _popup.is_item_checked(i):
			_popup.set_item_checked(i, false)
	
	var is_checked := _popup.is_item_checked(idx)
	_popup.set_item_checked(idx, not is_checked)
#endregion
