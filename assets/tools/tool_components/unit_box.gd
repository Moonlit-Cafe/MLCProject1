class_name UnitBox extends VBoxContainer

@export var unit_name_label : Label
@export var unit_name : String = "" :
	set(value) :
		unit_name = value
		if unit_name_label != null :
			unit_name_label.text = value
	get : return unit_name

@export var health_box : StatsLabel
@export var aether_box : StatsLabel
@export var movement_box : StatsLabel
@export var character : CharacterResource

var tile_rep : TileEntity

func _ready() -> void:
	if not character:
		push_error("UnitBox: There is no character to use for consideration...")
		return
	
	if character is EnemyCharacter:
		tile_rep = TileEnemy.new()
		add_to_group(&"enemy")
	elif character is PlayerCharacter:
		tile_rep = TilePlayer.new()
		add_to_group(&"player")
	
	if tile_rep != null:
		tile_rep.character = character

func update() -> void :
	pass
