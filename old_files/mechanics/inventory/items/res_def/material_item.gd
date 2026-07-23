class_name MaterialItem extends Item

@export var material_type : Genum.MaterialType

func load_data(data: Dictionary) -> void:
	super(data)
	material_type = data.get("material_type")

func save_data() -> Dictionary:
	var data = super()
	data.set("material_type", material_type)
	return data

func get_manager_data() -> Dictionary[StringName, Variant]:
	var data = super()
	data.set(&"material_type", material_type)
	return data
