class_name DataButton extends Button

signal send_data(data: Variant)

var data : Variant = null

func _pressed() -> void:
	send_data.emit(data)
