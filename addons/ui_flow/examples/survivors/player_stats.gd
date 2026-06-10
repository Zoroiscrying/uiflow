## Player stats — reactive data store for Survivors HUD.
class_name SurvivorsPlayerStats extends UIFlowDataStore

signal health_changed(value: float)
signal max_health_changed(value: float)
signal mana_changed(value: float)
signal max_mana_changed(value: float)
signal xp_changed(value: float)
signal xp_to_next_changed(value: float)
signal level_changed(value: int)
signal gold_changed(value: int)
signal attack_changed(value: int)

var max_health: float = 100.0:
	set(v): max_health = v; max_health_changed.emit(max_health)

var health: float = 100.0:
	set(v): health = clampf(v, 0.0, max_health); health_changed.emit(health)

var max_mana: float = 50.0:
	set(v): max_mana = v; max_mana_changed.emit(max_mana)

var mana: float = 50.0:
	set(v): mana = clampf(v, 0.0, max_mana); mana_changed.emit(mana)

var xp: float = 0.0:
	set(v): xp = v; xp_changed.emit(xp)

var xp_to_next: float = 100.0:
	set(v): xp_to_next = v; xp_to_next_changed.emit(xp_to_next)

var level: int = 1:
	set(v): level = maxi(v, 1); level_changed.emit(level)

var gold: int = 0:
	set(v): gold = maxi(v, 0); gold_changed.emit(gold)

var attack: int = 10:
	set(v): attack = maxi(v, 0); attack_changed.emit(attack)

func take_damage(amount: float) -> void:
	health -= amount

func heal(amount: float) -> void:
	health += amount

func use_mana(amount: float) -> bool:
	if mana < amount:
		return false
	mana -= amount
	return true

func add_xp(amount: float) -> void:
	xp += amount
	while xp >= xp_to_next:
		xp -= xp_to_next
		level += 1
		xp_to_next *= 1.5
		max_health += 10
		health = max_health
		max_mana += 5
		mana = max_mana
		attack += 2
