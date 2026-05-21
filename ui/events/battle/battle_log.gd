## Handles all the logging within the Battle Event Scene
extends VBoxContainer

#region Declarations
signal fade_node(node: Node)

@export var fade_delay : float = 5

var logged_items : Dictionary[Node, float] = {}
#endregion

# TODO: The kinds of stuff to log in this include but are not limited to:
# - Enemy Defeated
# - Gold
# - Items (If any)
# - Skill Usage
# - Stat changes to both player and enemy.

#region Events
func _ready() -> void:
	fade_node.connect(_on_node_faded)
#endregion

#region Processing
func _process(delta: float) -> void:
	for node in logged_items.keys():
		logged_items.set(node, logged_items.get(node) - delta)
		if logged_items.get(node) <= 0:
			var tween = get_tree().create_tween().bind_node(node)
			tween.tween_property(node, "modulate", Color(1, 1, 1, 0), 2)
			tween.finished.connect(func(): fade_node.emit(node))
#endregion

#region Publics
func log_item(text: String) -> void:
	var new_log := Label.new()
	new_log.text = text
	logged_items.set(new_log, 5)
	add_child(new_log)
#endregion

#region Signal Callbacks
func _on_node_faded(node: Node) -> void:
	logged_items.erase(node)
	remove_child(node)
#endregion
