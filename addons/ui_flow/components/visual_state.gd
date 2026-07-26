## Named discrete visual state: a list of NodePath → patch bindings.
class_name UIFlowVisualState extends Resource

@export var name: String = ""
@export var targets: Array[UIFlowVisualTarget] = []


func _init(p_name: String = "", p_targets: Array[UIFlowVisualTarget] = []) -> void:
	name = p_name
	targets = p_targets
