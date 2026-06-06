## Example data store — reactive player data with Signal-based change notification.
class_name PlayerData extends UIFlowDataStore

signal health_changed(value: float)
signal max_health_changed(value: float)
signal gold_changed(value: int)
signal is_alive_changed(value: bool)

var max_health: float = 100.0:
	set(v):
		max_health = v
		max_health_changed.emit(max_health)

var health: float = 100.0:
	set(v):
		health = clampf(v, 0.0, max_health)
		health_changed.emit(health)
		is_alive = health > 0.0

var gold: int = 0:
	set(v):
		gold = maxi(v, 0)
		gold_changed.emit(gold)

var is_alive: bool = true:
	set(v):
		is_alive = v
		is_alive_changed.emit(is_alive)
