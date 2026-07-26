## Ensures a container has exactly N children from a template (ReserveChildren).
##
## Unlike [UIFlowListBinder], this is count-driven — no data array required.
## Extra children are hidden (recycle) or freed depending on [member recycle_hidden].
class_name UIFlowChildPool extends Node

signal count_changed(active_count: int)

## Container that holds pooled children. Empty = parent of this node.
@export var container_path: NodePath = NodePath("..")
@export var template: PackedScene
@export var initial_count: int = 0
## When true, surplus instances are hidden and reused; when false, they are freed.
@export var recycle_hidden: bool = true

var _instances: Array[Node] = []
var _active_count: int = 0


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if initial_count > 0:
		ensure_count(initial_count)


func get_container() -> Node:
	if container_path.is_empty():
		return get_parent()
	return get_node_or_null(container_path)


func get_active_count() -> int:
	return _active_count


func get_active_children() -> Array[Node]:
	var result: Array[Node] = []
	for i in _active_count:
		if i < _instances.size() and is_instance_valid(_instances[i]):
			result.append(_instances[i])
	return result


## Ensures [param count] active children. [param init_fn] is [code]func(child, index)[/code]
## and is called for every active slot after resize (including reused ones).
func ensure_count(count: int, init_fn: Callable = Callable()) -> Array[Node]:
	count = maxi(count, 0)
	var container := get_container()
	if container == null:
		push_warning("UIFlowChildPool: container not found (%s)" % String(container_path))
		return []
	if template == null and count > _instances.size():
		push_warning("UIFlowChildPool: template is null, cannot grow")
		count = mini(count, _instances.size())

	# Grow
	while _instances.size() < count:
		var inst: Node = template.instantiate()
		container.add_child(inst)
		_instances.append(inst)

	# Activate / deactivate
	for i in _instances.size():
		var inst: Node = _instances[i]
		if not is_instance_valid(inst):
			continue
		var active: bool = i < count
		if inst is CanvasItem:
			(inst as CanvasItem).visible = active
		elif not active and not recycle_hidden:
			pass
		if active and init_fn.is_valid():
			init_fn.call(inst, i)

	if not recycle_hidden and _instances.size() > count:
		for i in range(_instances.size() - 1, count - 1, -1):
			var extra: Node = _instances[i]
			_instances.remove_at(i)
			if is_instance_valid(extra):
				extra.queue_free()

	_active_count = count
	count_changed.emit(_active_count)
	return get_active_children()


func clear() -> void:
	for inst in _instances:
		if is_instance_valid(inst):
			inst.queue_free()
	_instances.clear()
	_active_count = 0
	count_changed.emit(0)


## Static helper: ensure [param count] children under [param container].
static func reserve(
	container: Node,
	count: int,
	p_template: PackedScene,
	init_fn: Callable = Callable(),
	recycle: bool = true,
) -> Array[Node]:
	var pool := UIFlowChildPool.new()
	pool.template = p_template
	pool.recycle_hidden = recycle
	container.add_child(pool)
	pool.container_path = NodePath("..")
	return pool.ensure_count(count, init_fn)
