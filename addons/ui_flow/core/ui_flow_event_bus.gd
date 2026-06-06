## Event Bus — decoupled cross-system communication via native Godot Signals.
##
## Define your game events as signals on a custom EventBus script that extends this class.
## Systems emit events; UI (or anything else) subscribes independently.
##
## Example:
## [codeblock]
## # game_events.gd
## class_name GameEvents extends UIFlowEventBus
## signal player_died
## signal item_acquired(item_id: StringName, count: int)
## signal quest_completed(quest_id: StringName)
##
## # In game logic:
## GameEvents.player_died.emit()
## GameEvents.item_acquired.emit("sword_01", 1)
##
## # In UI:
## GameEvents.player_died.connect(_on_player_died)
## GameEvents.item_acquired.connect(_on_item_acquired)
## [/codeblock]
class_name UIFlowEventBus extends Node

## Alternative: register events dynamically at runtime.
## Useful for plugin/mod systems where events aren't known at compile time.
var _dynamic_events: Dictionary = {} # StringName -> Signal

## Register a dynamic event by name.
## Returns the signal for immediate connection.
func register(event_name: StringName) -> Signal:
	if _dynamic_events.has(event_name):
		return _dynamic_events[event_name]
	# Create a new signal on this object
	add_user_signal(event_name)
	_dynamic_events[event_name] = Signal(self, event_name)
	return _dynamic_events[event_name]

## Emit a dynamic event by name with optional data.
func emit_event(event_name: StringName, data: Dictionary = {}) -> void:
	if _dynamic_events.has(event_name):
		if data.is_empty():
			_dynamic_events[event_name].emit()
		else:
			_dynamic_events[event_name].emit(data)
	else:
		push_warning("UIFlowEventBus: Event '%s' not registered." % event_name)
