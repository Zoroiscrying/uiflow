## UIFlowUtils — common UI utility functions.
##
## Provides tree traversal, child management, and batch operations
## that are frequently needed in game UI development.
class_name UIFlowUtils

# ── Traverse / Find ──────────────────────────────────────────────────────────

## Iterate over all direct children of a node.
## [codeblock]
## UIFlowUtils.for_each_child($Container, func(child, index):
##     child.visible = index < 5
## )
## [/codeblock]
static func for_each_child(node: Node, callback: Callable) -> void:
	for i in range(node.get_child_count()):
		var child := node.get_child(i)
		callback.call(child, i)


## Iterate over all descendants (recursive).
static func for_each_descendant(node: Node, callback: Callable) -> void:
	for child in node.get_children():
		callback.call(child)
		for_each_descendant(child, callback)


## Find first child matching a predicate.
## [codeblock]
## var btn = UIFlowUtils.find_child($Container, func(child): return child is Button)
## [/codeblock]
static func find_child(node: Node, predicate: Callable) -> Node:
	for child in node.get_children():
		if predicate.call(child):
			return child
	return null


## Find all children matching a predicate.
static func find_children(node: Node, predicate: Callable) -> Array:
	var result: Array = []
	for child in node.get_children():
		if predicate.call(child):
			result.append(child)
	return result


## Find first child by type.
static func find_childByType(node: Node, type: Variant) -> Node:
	return find_child(node, func(child): return is_instance_of(child, type))


## Find all children by type.
static func find_childrenByType(node: Node, type: Variant) -> Array:
	return find_children(node, func(child): return is_instance_of(child, type))


## Find child by name (direct child only).
static func find_childByName(node: Node, child_name: String) -> Node:
	for child in node.get_children():
		if child.name == child_name:
			return child
	return null


## Find descendant by name (recursive).
static func find_descendant_by_name(node: Node, desc_name: String) -> Node:
	for child in node.get_children():
		if child.name == desc_name:
			return child
		var found := find_descendant_by_name(child, desc_name)
		if found:
			return found
	return null


# ── reserve_children ──────────────────────────────────────────────────────────

## Ensure a parent has exactly [code]count[/code] children.
## Creates or frees children as needed using [code]template[/code] scene.
## Calls [code]on_update(child, index)[/code] for each child after creation.
##
## [codeblock]
## # Ensure inventory grid has exactly 20 slots
## UIFlowUtils.reserve_children($Grid, 20, slot_scene, func(slot, i):
##     slot.SetItem(inventory[i])
## )
## [/codeblock]
static func reserve_children(parent: Node, count: int, template: PackedScene, on_update: Callable = Callable()) -> void:
	var current_count: int = parent.get_child_count()

	# Create missing children
	while parent.get_child_count() < count:
		var instance: Node = template.instantiate()
		parent.add_child(instance)

	# Free excess children
	while parent.get_child_count() > count:
		var last: Node = parent.get_child(parent.get_child_count() - 1)
		parent.remove_child(last)
		last.queue_free()

	# Update all children
	if on_update.is_valid():
		for i in range(count):
			var child: Node = parent.get_child(i)
			on_update.call(child, i)


## Same as reserve_children but uses a factory function instead of a scene.
## [codeblock]
## UIFlowUtils.reserve_childrenFactory($List, 10, func(): return Label.new(), func(label, i):
##     label.text = "Item %d" % i
## )
## [/codeblock]
static func reserve_childrenFactory(parent: Node, count: int, factory: Callable, on_update: Callable = Callable()) -> void:
	var current_count: int = parent.get_child_count()

	while parent.get_child_count() < count:
		var instance: Node = factory.call()
		parent.add_child(instance)

	while parent.get_child_count() > count:
		var last: Node = parent.get_child(parent.get_child_count() - 1)
		parent.remove_child(last)
		last.queue_free()

	if on_update.is_valid():
		for i in range(count):
			var child: Node = parent.get_child(i)
			on_update.call(child, i)


# ── Batch Operations ─────────────────────────────────────────────────────────

## Set visibility on multiple nodes.
## [codeblock]
## UIFlowUtils.set_visible([$HP, $MP, $Gold], true)
## [/codeblock]
static func set_visible(nodes: Array, visible: bool) -> void:
	for node in nodes:
		if is_instance_valid(node) and node is Control:
			node.visible = visible


## Set modulate alpha on multiple nodes.
static func set_alpha(nodes: Array, alpha: float) -> void:
	for node in nodes:
		if is_instance_valid(node) and node is CanvasItem:
			node.modulate.a = alpha


## Enable or disable multiple buttons.
static func set_buttons_enabled(buttons: Array, enabled: bool) -> void:
	for btn in buttons:
		if is_instance_valid(btn) and btn is BaseButton:
			btn.disabled = not enabled


## Set text on multiple labels.
static func set_texts(labels: Array, texts: Array) -> void:
	for i in range(min(labels.size(), texts.size())):
		if is_instance_valid(labels[i]) and labels[i] is Label:
			labels[i].text = str(texts[i])


## Remove all children from a node.
static func clear_children(parent: Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()


## Get all children as a typed array.
static func get_children_of_type(node: Node, type: Variant) -> Array:
	var result: Array = []
	for child in node.get_children():
		if is_instance_of(child, type):
			result.append(child)
	return result
