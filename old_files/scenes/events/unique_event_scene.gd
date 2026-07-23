extends BaseEventScene

@export var events : Array[UniqueEventList]

var event_id : int = 0
var choices_available : PackedStringArray = []
var risk_level : int = 0

func _ready() -> void:
	if events.size() == 0:
		return
	
	var event_list : UniqueEventList = events.get(randi_range(0, events.size() - 1))
	if event_list.event_list.size() == 0:
		return
	
	var event : UniqueEvent = event_list.event_list.get(randi_range(0, event_list.event_list.size() - 1))
	event.call_event()

func _on_pressed() -> void:
	SceneManager.load_next_scene()
