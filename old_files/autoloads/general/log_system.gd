class_name LogSystem extends Node

#region Declarations
var _log_file : Array[String] = []
#endregion

#region Events
# TODO: Make it save to a file for complete logging.
func post_message(node: Node, message: String) -> void:
	var node_name : String = "NA"
	if node:
		node_name = node.name
	var post_str : String = "@%s: %s" % [node_name, message]
	_log_file.append(post_str)
	print(post_str)

func post_warning(node: Node, message: String) -> void:
	var warning_str : String = _get_post_message(node, message, "Warning")
	_log_file.append(warning_str)
	print(warning_str)
	push_warning(message)

func post_error(node: Node, message: String):
	var error_str : String = _get_post_message(node, message, "Error")
	_log_file.append(error_str)
	print(error_str)
	push_error(message)

func _get_post_message(node: Node, message: String, prefix: String) -> String:
	if not node:
		return "%s -- @NA: %s" % [prefix, message]
	
	var node_splice : PackedStringArray = node.get_path().get_concatenated_names().split("/")
	var node_path_str : String = "%s -- @%s/%s: " % [
		prefix,
		node_splice.get(node_splice.size() - 2),
		node_splice.get(node_splice.size() - 1)]
	var return_string : String = "%s%s" % [node_path_str, message]
	return return_string
#endregion
