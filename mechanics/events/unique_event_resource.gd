class_name UniqueEvent extends Resource

@export var name : StringName
@export var description : String
@export var event_script : String

func call_event() -> void:
	var expr = Expression.new()
	expr.parse(event_script)
	expr.execute()
