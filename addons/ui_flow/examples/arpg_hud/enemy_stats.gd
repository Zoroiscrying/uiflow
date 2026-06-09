## Enemy stats — reactive data for enemy health bars.
class_name ARPGEnemyStats extends UIFlowDataStore

signal health_changed(value: float)
signal max_health_changed(value: float)
signal name_changed(value: String)

var enemy_name: String = "Enemy":
	set(v): enemy_name = v; name_changed.emit(enemy_name)

var max_health: float = 50.0:
	set(v): max_health = v; max_health_changed.emit(max_health)

var health: float = 50.0:
	set(v): health = clampf(v, 0.0, max_health); health_changed.emit(health)

var attack: int = 5

func take_damage(amount: float) -> void:
	health -= amount

func is_alive() -> bool:
	return health > 0.0
