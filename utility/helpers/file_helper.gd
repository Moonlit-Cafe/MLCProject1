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
			for key in json.data.keys():
				var key_data : Dictionary = {}
				for data in json.data.get(key).keys():
					var data_value = dmh.detect_special_data(json.data.get(key).get(data))
					key_data.set(data, data_value)
				database.set(key, key_data)
		GameGlobal.logging.post_message(null, "Database from file %s successfully loaded." % file_path)
	else:
		GameGlobal.logging.post_warning(null, "JSON Parse Error: %s at line %d in file %s" % [
			json.get_error_message(), json.get_error_line(), file_path
		])
	
	return database

static func save_database(file_path: String, database: Dictionary) -> void:
	var dmh := DataManipulationHelper.new()
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	var str_data : Dictionary = {}
	for key in database.keys():
		var str_key_data : Dictionary = {}
		for data in database.get(key).keys():
			var data_value = dmh.encode_special_data(data)
			str_key_data.set(data, data_value)
		str_data.set(key, str_key_data)
	
	var json_string = JSON.stringify(str_data, "\t")
	file.store_string(json_string)
	file.close()

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
