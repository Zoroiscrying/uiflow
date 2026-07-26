## One NodePath target and its optional visual patch.
class_name UIFlowVisualTarget extends Resource

@export var node_path: NodePath = NodePath()
@export var patch: UIFlowVisualPatch


func _init(p_node_path: NodePath = NodePath(), p_patch: UIFlowVisualPatch = null) -> void:
	node_path = p_node_path
	patch = p_patch
