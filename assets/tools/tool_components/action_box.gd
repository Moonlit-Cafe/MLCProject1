class_name ActionBox extends VBoxContainer

@export var ability : String

@export var name_label : Label
@export var name_label_text : String = "" :
	set(value) :
		name_label_text = value
		name_label.text = value
	get: return name_label_text

@export var ac_desc_label : Label
@export var ac_desc_text : String = "" :
	set(value) :
		ac_desc_text = value
		ac_desc_label.text = value
	get: return ac_desc_text

@export var amt_label : Label
@export var amt_label_text : String = "" :
	set(value) :
		amt_label_text = value
		amt_label.text = value
	get: return amt_label_text
	
@export var ab : Button

func _ready() -> void:
	ab.text = name_label_text

func _on_action_pressed() -> void:
	
	## TODO: Handle action from being pressed
	# Update movement distance
	# Update Health
	# Update Mana
	# etc...
	# likely emit signal to do our thing.
	print(name_label_text)
	match name_label_text :
		"LightAttack" :
			GameGlobalEvents.act.emit("light", "enemy")
		"HeavyAttack" :
			GameGlobalEvents.act.emit("heavy", "enemy")
		"MagicAttack" :
			GameGlobalEvents.act.emit("magic", "enemy")
		_:
			# Do nothing if we just end the turn without matching an action name.
			pass
	
	pass # Replace with function body.
