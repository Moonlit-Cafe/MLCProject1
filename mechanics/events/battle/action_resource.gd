## Handles the data in regards to all combat-based actions from sword swings to 
## to spell flings.
class_name Action extends Resource

#region Declaration
@export var ac_name : StringName
@export var ac_id : StringName
@export var shape : ActionShape
@export var damage_type : Genum.DamageType
@export var value : float = 1
#endregion
