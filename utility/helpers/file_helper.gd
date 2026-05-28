## Contains any and all methods relating to file handling that are helpful.
class_name FileHelper

static func load_database(file_path: String) -> Dictionary:
	var database : Dictionary = {}
	var dmh := DataManipulationHelper.new()
	
	if not FileAccess.file_exists(file_path):
		GameGlobal.logging.post_warning(null, "File %s does not exist." % file_path)
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		if json.data is Dictionary:
			print(json.data)
			database = load_dictionary(json.data)
		GameGlobal.logging.post_message(null, "Database from file %s successfully loaded." % file_path)
	else:
		GameGlobal.logging.post_warning(null, "JSON Parse Error: %s at line %d in file %s" % [
			json.get_error_message(), json.get_error_line(), file_path
		])
	
	return database

static func load_dictionary(dict: Dictionary) -> Dictionary:
	var dmh := DataManipulationHelper.new()
	var loaded_dict : Dictionary = {}
	for key in dict.keys():
		var value = dict.get(key)
		if value is Dictionary:
			value = load_dictionary(value)
		else:
			value = dmh.detect_special_data(value)
		
		loaded_dict.set(key, value)
	return loaded_dict

static func save_database(file_path: String, database: Dictionary) -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	var str_data : Dictionary = save_dictionary(database)
	
	var json_string = JSON.stringify(str_data, "\t")
	file.store_string(json_string)
	file.close()

static func save_dictionary(dict: Dictionary) -> Dictionary:
	var dmh := DataManipulationHelper.new()
	var saved_dict : Dictionary = {}
	for key in dict.keys():
		var value = dict.get(key)
		if value is Dictionary:
			value = save_dictionary(dict)
		else:
			value = dmh.encode_special_data(value)
		
		saved_dict.set(key, value)
	return saved_dict

## Used specifically with Web export to load assets because of how export name-changing works.
static func load_asset(path : String) -> Resource:
	if OS.has_feature("export"):
		# Check if file is .remap
		if not path.ends_with(".remap"):
			return load(path)
		
		# Open the file
		var __config_file = ConfigFile.new()
		__config_file.load(path)
		
		# Load the remapped file
		var __remapped_file_path = __config_file.get_value("remap", "path")
		__config_file = null
		return load(__remapped_file_path)
	else:
		return load(path)
