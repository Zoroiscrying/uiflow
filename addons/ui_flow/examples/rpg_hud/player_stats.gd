## Player stats — reactive data store for RPG HUD.
class_name PlayerStats extends UIFlowDataStore

signal health_changed(value: float)
signal max_health_changed(value: float)
signal mana_changed(value: float)
signal max_mana_changed(value: float)
signal gold_changed(value: int)
signal level_changed(value: int)

var max_health: float = 100.0:
	set(v): max_health = v; max_health_changed.emit(max_health)

var health: float = 100.0:
	set(v): health = clampf(v, 0.0, max_health); health_changed.emit(health)

var max_mana: float = 50.0:
	set(v): max_mana = v; max_mana_changed.emit(max_mana)

var mana: float = 50.0:
	set(v): mana = clampf(v, 0.0, max_mana); mana_changed.emit(mana)

var gold: int = 0:
	set(v): gold = maxi(v, 0); gold_changed.emit(gold)

var level: int = 1:
	set(v): level = maxi(v, 1); level_changed.emit(level)
