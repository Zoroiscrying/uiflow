## UIFlowListBinder — binds an array signal to a UI template list.
##
## Automatically creates/updates/destroys UI instances when the array changes.
## Supports stable identity via an optional key function.
##
## Usage:
## [codeblock]
## # Index-based (default) — instances are bound by position
## var binder = UIFlow.bind_list(
##     $GridContainer,
##     player_data.inventory_changed,
##     preload("res://item_slot.tscn"),
##     func(slot, item, index): slot.setup(item)
## )
##
## # Identity-based — instances are bound by item ID, preserving identity across reordering
## var binder = UIFlow.bind_list(
##     $GridContainer,
##     player_data.inventory_changed,
##     preload("res://item_slot.tscn"),
##     func(slot, item, index): slot.setup(item),
##     func(item, index): return item.item_id
## )
## # Later: binder.unbind()
## [/codeblock]
class_name UIFlowListBinder extends RefCounted

var _container: Node
var _template: PackedScene
var _binder: Callable
var _key_func: Callable
var _signal: Signal
var _instances: Array[Control] = []
var _item_keys: Array = []


func _init(
	container: Node,
	sig: Signal,
	template: PackedScene,
	binder: Callable,
	key_func: Callable = Callable(),
) -> void:
	_container = container
	_template = template
	_binder = binder
	_key_func = key_func
	_signal = sig
	_signal.connect(_on_data_changed)


func _on_data_changed(items: Array) -> void:
	_update_list(items)


func _update_list(items: Array) -> void:
	var new_keys := _compute_keys(items)

	# Build map: key -> instance (from current instances)
	var instance_map: Dictionary = {}
	for i in range(_instances.size()):
		instance_map[_item_keys[i]] = _instances[i]

	# Reorder / resize to match new items, reusing existing instances
	var new_instances: Array[Control] = []
	for i in range(items.size()):
		var key = new_keys[i]
		var instance: Control
		if instance_map.has(key):
			instance = instance_map[key]
			instance_map.erase(key)  # mark as used
		else:
			instance = _template.instantiate() as Control
			_container.add_child(instance)
		new_instances.append(instance)
		_binder.call(instance, items[i], i)

	# Destroy unused instances
	for unused in instance_map.values():
		if is_instance_valid(unused):
			_container.remove_child(unused)
			unused.queue_free()

	_instances = new_instances
	_item_keys = new_keys


func _compute_keys(items: Array) -> Array:
	var keys: Array = []
	if _key_func.is_valid():
		for i in range(items.size()):
			keys.append(_key_func.call(items[i], i))
	else:
		# Index-based identity
		for i in range(items.size()):
			keys.append(i)
	return keys


## Disconnect the binding. Call when the page is closed.
func unbind() -> void:
	if _signal.is_connected(_on_data_changed):
		_signal.disconnect(_on_data_changed)
	for inst in _instances:
		if is_instance_valid(inst):
			inst.queue_free()
	_instances.clear()
	_item_keys.clear()
