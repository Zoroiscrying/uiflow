## Game events — event bus for cross-system communication.
class_name GameEvents extends UIFlowEventBus

signal player_died
signal level_up(new_level: int)
signal item_acquired(item_id: StringName, count: int)
