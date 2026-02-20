class_name MaterialItem extends Item

@export var material_type : Genum.MaterialType

func load_data(data: Dictionary) -> void:
	super(data)
	var dmh = DataManipulationHelper.new()
	material_type = dmh.detect_special_data(data.get("material_type"))

func save_data() -> Dictionary:
	var data = super()
	data.set("material_type", "%s" % material_type)
	return data
