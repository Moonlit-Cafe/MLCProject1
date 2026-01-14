class_name TilePlayer extends TileEntity

#region Declarations
signal overlap_checked

@export var default_range : float = 2.

@onready var detect_sphere : Area3D = $DetectionSphere
@onready var coll_shape : CollisionShape3D = $DetectionSphere/CollisionShape3D

var d_range : float = 1. :
	set(value):
		_set_detect_radius(value)
		d_range = value
var coll_sphere : SphereShape3D
var overlap : Array[Area3D]
var check_overlap := false
var haste : int
#endregion

#region Events
func _ready() -> void:
	coll_sphere = coll_shape.shape
	d_range = default_range

func get_detected() -> Array[BattleTile]:
	check_overlap = true
	await overlap_checked
	var ret_arr : Array[BattleTile] = []
	
	for area in overlap:
		var area_parent = area.get_parent()
		if area_parent is BattleTile:
			ret_arr.append(area_parent)
	
	return ret_arr

func _set_detect_radius(radius: float) -> void:
	if not coll_sphere:
		return
	
	print("Setting Col Sphere to ", radius)
	coll_sphere.radius = radius

func update() -> void:
	haste = character.haste
	super()

func defend(value: float, _offender: TileEntity) -> void:
	super(value, _offender)
	if stats.get(Genum.StatType.HEALTH) <= 0:
		get_tree().quit()
#endregion

#region Processes
func _physics_process(_delta: float) -> void:
	if check_overlap:
		overlap = detect_sphere.get_overlapping_areas()
		overlap_checked.emit()
		check_overlap = false
#endregion
