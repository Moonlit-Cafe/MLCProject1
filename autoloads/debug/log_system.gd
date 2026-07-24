## Handles the process of posting messages, warnings, and errors while also saving them for
## later use when debugging.
extends Node

#region Declarations
const LOG_MAX : int = 5

var _log_data : Array[String] = [] ## The runtime log of all posted messages.
#endregion

#region Events
## Used to save [member _log_data] to a file during game end.
func save_log() -> void:
	_check_log_count()
	
	var date_time := Time.get_datetime_dict_from_system()
	var date_time_str : String = "%s%s%s_%s%s%s" % [
		date_time.get("year"),
		date_time.get("month"),
		date_time.get("day"),
		date_time.get("hour"),
		date_time.get("minute"),
		date_time.get("second")
		]
	var log_file := FileAccess.open("user://logs/log_%s" % date_time_str, FileAccess.WRITE)
	for log_str in _log_data:
		log_file.store_line(log_str)
	
	log_file.close()
	print("Log Saved, successfully")

## Posts a regular message to console and saves to [member _log_data]
func post_message(node: Node, message: String) -> void:
	_post(node, message, "Message")

## Posts a warning message to console and saves to [member _log_data]
func post_warning(node: Node, message: String) -> void:
	_post(node, message, "Warning")
	push_warning(message)

## Posts an error message to console and saves to [member _log_data]
func post_error(node: Node, message: String) -> void:
	_post(node, message, "Error")
	push_error(message)

## The base method used for posting messages to console, with [param prefix] for determining
## what to specify the message as. Often: Message, Warning, Error
func _post(node: Node, message: String, prefix: String) -> void:
	var post_str : String = ""
	var node_path : String = node.get_path()
	if not node:
		post_str = "%s: \"%s\" at NA" % [prefix, message]
	else:
		post_str = "%s: \"%s\" at %s" % [prefix, message, node_path]
	
	_log_data.append(post_str)
	print(post_str)

## Checks if the amount of logs besides log_latest, and if over, deletes.
func _check_log_count() -> void:
	var log_dir := DirAccess.open("user://logs/")
	if not log_dir:
		return
	
	if log_dir.get_files().size() == LOG_MAX:
		log_dir.remove(log_dir.get_files().get(0))
#endregion
