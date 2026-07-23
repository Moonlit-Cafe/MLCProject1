class_name CraftButton extends Button

signal craft_requested(button_name: StringName)

func _pressed() -> void:
	craft_requested.emit(text.to_snake_case())
