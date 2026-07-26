## Shows exactly one of several targets at a time (mutually exclusive visibility).
class_name UIFlowVisibilityGroup extends Node

signal active_changed(index: int)

@export var targets: Array[NodePath] = []
@export var active_index: int = 0:
	set(value):
		var next: int = value
		if not targets.is_empty():
			next = clampi(value, 0, targets.size() - 1)
		if active_index == next:
			if is_inside_tree():
				_apply_visibility()
			return
		active_index = next
		if is_inside_tree():
			_apply_visibility()


func _ready() -> void:
	_apply_visibility()


func get_target_count() -> int:
	return targets.size()


func set_active(index: int) -> void:
	active_index = index


func apply() -> void:
	_apply_visibility()


func _apply_visibility() -> void:
	if targets.is_empty():
		return
	var clamped: int = clampi(active_index, 0, targets.size() - 1)
	for i in targets.size():
		var node := get_node_or_null(targets[i])
		if node is CanvasItem:
			(node as CanvasItem).visible = (i == clamped)
	active_changed.emit(clamped)
