## UIFlowListBinder — binds an array signal to a UI template list.
##
## Automatically creates/updates/destroys UI instances when the array changes.
##
## Usage:
## [codeblock]
## var binder = UIFlow.bind_list(
##     $GridContainer,
##     player_data.inventory_changed,
##     preload("res://item_slot.tscn"),
##     func(slot, item, index): slot.setup(item)
## )
## [/codeblock]
class_name UIFlowListBinder extends RefCounted

var _container: Node
var _template: PackedScene
var _binder: Callable
var _signal: Signal
var _binding: UIFlowBindUtils.UIFlowBinding
var _instances: Array[Control] = []


func _init(
	container: Node,
	sig: Signal,
	template: PackedScene,
	binder: Callable,
) -> void:
	_container = container
	_template = template
	_binder = binder

	# Connect to the array signal
	_binding = UIFlowBindUtils.bind_signal_t(container, &"", sig, func(items: Array):
		_update_list(items)
	)
	# Disconnect the default property set (we handle it manually)
	_binding.unbind()
	# Reconnect without the property set
	_signal = sig
	_signal.connect(_on_data_changed)


func _on_data_changed(items: Array) -> void:
	_update_list(items)


func _update_list(items: Array) -> void:
	# Create/destroy instances to match array size
	while _instances.size() < items.size():
		var instance: Control = _template.instantiate()
		_container.add_child(instance)
		_instances.append(instance)

	while _instances.size() > items.size():
		var last: Control = _instances.pop_back()
		_container.remove_child(last)
		last.queue_free()

	# Update each instance
	for i in range(items.size()):
		_binder.call(_instances[i], items[i], i)


## Disconnect the binding. Call when the page is closed.
func unbind() -> void:
	if _signal.is_connected(_on_data_changed):
		_signal.disconnect(_on_data_changed)
	for inst in _instances:
		if is_instance_valid(inst):
			inst.queue_free()
	_instances.clear()
