## Handles the data in regards to all combat-based actions from sword swings to 
## to spell flings.
class_name Action extends Resource

#region Declaration
@export var ac_name : StringName ## The actual name for the action
@export var ac_id : StringName ## The id of the action, preferred to be in snake_case
@export var shape : ActionShape ## The required ActionShape for the action
#endregion
