## Handles the process of posting messages, warnings, and errors while also saving them for
## later use when debugging.
class_name LogSystem extends Node

#region Declarations
const LOG_MAX : int = 5

var _log_data : Array[String] = [] ## The runtime log of all posted messages.
#endregion

#region Events
func save_log() -> void:
	_check_log_count()
	
	var log_dir_path := "user://logs/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(log_dir_path))
	
	var date_time := Time.get_datetime_dict_from_system()
	var date_time_str : String = "%04d%02d%02d_%02d%02d%02d" % [
		date_time.get("year"),
		date_time.get("month"),
		date_time.get("day"),
		date_time.get("hour"),
		date_time.get("minute"),
		date_time.get("second")
		]
	var log_file := FileAccess.open("%slog_%s.txt" % [log_dir_path, date_time_str], FileAccess.WRITE)
	if log_file == null:
		push_error("Could not open the log file for writing: %s" % error_string(FileAccess.get_open_error()))
		return
	for log_str in _log_data:
		log_file.store_line(log_str)
	
	log_file.close()
	#print("Log Saved, successfully")

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
	if node == null:
		post_str = "%s: \"%s\" at NA" % [prefix, message]
	else:
		post_str = "%s: \"%s\" at %s" % [prefix, message, node.get_path()]
	
	_log_data.append(post_str)
	print(post_str)

func _check_log_count() -> void:
	var log_dir := DirAccess.open("user://logs/")
	if not log_dir:
		return
	
	var files : Array[String] = []
	files.assign(log_dir.get_files())
	if files.size() < LOG_MAX:
		return
	
	files.sort_custom(func(a: String, b: String) -> bool:
		var path_a := "user://logs/%s" % a
		var path_b := "user://logs/%s" % b
		return FileAccess.get_modified_time(path_a) < FileAccess.get_modified_time(path_b)
	)
	
	while files.size() >= LOG_MAX:
		log_dir.remove(files.pop_front())
#endregion
