class_name EventButton extends Button

signal next_event(event_holder: EventPoint)

var event : EventPoint

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	next_event.emit(event)
