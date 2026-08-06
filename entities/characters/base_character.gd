class_name BaseCharacter extends Resource

#region Declarations
enum CharType {
	PLAYER,
	ENEMY
}

@export var name : StringName = &"" ## Name of the character
@export var id : StringName
@export var type : CharType = CharType.ENEMY
@export var stats : Dictionary[Genum.StatType, float] = {
	Genum.StatType.HEALTH: 10.0
}
@export var frames : SpriteFrames ## The frames representing the 2D character
#endregion

#region Events
static func create_character_data(data: Dictionary, new_id: String) -> BaseCharacter:
	var new_char := BaseCharacter.new()
	new_char.name = data.get("name", &"New Character")
	new_char.id = new_id
	new_char.type = data.get("type", 1) as CharType
	if not ResourceLoader.exists(data.get("frames", "")):
		new_char.frames = SpriteFrames.new()
		return new_char
	
	var new_frames : SpriteFrames = ResourceLoader.load(data.get("frames"))
	new_char.frames = new_frames
	return new_char
#endregion
