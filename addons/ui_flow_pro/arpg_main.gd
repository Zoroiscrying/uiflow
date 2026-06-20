## SurvivorsMain — wave survival game controller with EventBus integration.
extends Node3D

@export var player_stats: SurvivorsPlayerStats

var _wave: int = 0
var _enemies_alive: int = 0
var _wave_timer: float = 0.0
var _between_waves: bool = true
var _wave_cooldown: float = 3.0
var _xp_to_next_level: float = 100.0

var _inventory_data: InventoryData
var _equipment_data: EquipmentData
var _shop_items: Array[ItemData] = []
var _level_up_weapons: Array[WeaponData] = []
var _kill_tracker: Dictionary = {}
var _event_bus: SurvivorsEventBus

@onready var _player: CharacterBody3D = $Player
@onready var _spawn_points: Node3D = $SpawnPoints


func _ready() -> void:
	if player_stats == null:
		player_stats = SurvivorsPlayerStats.new()

	_setup_inventory()
	_setup_equipment()
	_setup_shop_items()
	_setup_level_up_weapons()
	_setup_event_bus()
	_setup_player()

	await get_tree().process_frame

	UIFlow.push(SurvivorsHUDPage, {"player_stats": player_stats})

	_between_waves = true
	_wave_timer = 2.0


func _setup_inventory() -> void:
	_inventory_data = InventoryData.new(20)


func _setup_equipment() -> void:
	_equipment_data = EquipmentData.new()


func _setup_shop_items() -> void:
	var sword := ItemData.new()
	sword.item_name = "Iron Sword"
	sword.description = "A sturdy iron blade. ATK +5"
	sword.type = ItemData.Type.WEAPON
	sword.rarity = ItemData.Rarity.COMMON
	sword.sell_price = 25
	sword.equip_slot = &"weapon"
	sword.bonus_attack = 5

	var shield := ItemData.new()
	shield.item_name = "Wooden Shield"
	shield.description = "Blocks incoming damage. DEF +3, HP +20"
	shield.type = ItemData.Type.ARMOR
	shield.rarity = ItemData.Rarity.COMMON
	shield.sell_price = 30
	shield.equip_slot = &"chest"
	shield.bonus_defense = 3
	shield.bonus_health = 20

	var ring := ItemData.new()
	ring.item_name = "Mana Ring"
	ring.description = "Restores arcane energy. MP +15"
	ring.type = ItemData.Type.ACCESSORY
	ring.rarity = ItemData.Rarity.UNCOMMON
	ring.sell_price = 50
	ring.equip_slot = &"accessory"
	ring.bonus_mana = 15

	var potion := ItemData.new()
	potion.item_name = "Health Potion"
	potion.description = "Restores 50 HP on use."
	potion.type = ItemData.Type.CONSUMABLE
	potion.rarity = ItemData.Rarity.COMMON
	potion.sell_price = 10

	var epic_blade := ItemData.new()
	epic_blade.item_name = "Flame Blade"
	epic_blade.description = "Burns with eternal fire. ATK +12, HP +10"
	epic_blade.type = ItemData.Type.WEAPON
	epic_blade.rarity = ItemData.Rarity.EPIC
	epic_blade.sell_price = 120
	epic_blade.equip_slot = &"weapon"
	epic_blade.bonus_attack = 12
	epic_blade.bonus_health = 10

	_shop_items = [sword, shield, ring, potion, epic_blade]


func _setup_level_up_weapons() -> void:
	var pistol := WeaponData.new()
	pistol.weapon_name = "Pistol"
	pistol.description = "A reliable sidearm."
	pistol.type = WeaponData.Type.BULLET
	pistol.rarity = WeaponData.Rarity.COMMON
	pistol.cooldown = 0.3
	pistol.damage = 8
	pistol.range = 12.0
	pistol.sell_price = 15

	var shotgun := WeaponData.new()
	shotgun.weapon_name = "Shotgun"
	shotgun.description = "Close range devastation."
	shotgun.type = WeaponData.Type.BULLET
	shotgun.rarity = WeaponData.Rarity.UNCOMMON
	shotgun.cooldown = 0.8
	shotgun.damage = 20
	shotgun.range = 6.0
	shotgun.sell_price = 30

	var laser := WeaponData.new()
	laser.weapon_name = "Laser"
	laser.description = "Piercing beam of light."
	laser.type = WeaponData.Type.BULLET
	laser.rarity = WeaponData.Rarity.RARE
	laser.cooldown = 0.15
	laser.damage = 5
	laser.range = 15.0
	laser.sell_price = 50

	_level_up_weapons = [pistol, shotgun, laser]


func _setup_event_bus() -> void:
	# Use autoload if available, otherwise create local instance
	var autoload := get_node_or_null("/root/SurvivorsEventBus")
	if autoload is SurvivorsEventBus:
		_event_bus = autoload
	else:
		_event_bus = SurvivorsEventBus.new()
		_event_bus.name = "SurvivorsEventBus"
		add_child(_event_bus)
	_event_bus.xp_gained.connect(_on_xp_gained)


func _setup_player() -> void:
	_player.stats = player_stats
	_player.set_top_down_camera()

	var starter := WeaponData.new()
	starter.weapon_name = "Starter Pistol"
	starter.description = "Your trusty sidearm."
	starter.type = WeaponData.Type.BULLET
	starter.cooldown = 0.3
	starter.damage = 5
	starter.range = 10.0
	player_stats.add_weapon(starter)

	var weapon_mgr_script = preload("res://addons/ui_flow_pro/weapon_manager.gd")
	var weapon_mgr = weapon_mgr_script.new()
	weapon_mgr.name = "WeaponManager"
	_player.add_child(weapon_mgr)
	weapon_mgr.setup(player_stats)
	_player._weapon_manager = weapon_mgr


func _process(delta: float) -> void:
	if _between_waves:
		_wave_timer -= delta
		if _wave_timer <= 0:
			_start_wave()
	else:
		_enemies_alive = get_tree().get_nodes_in_group("enemies").size()
		if _enemies_alive == 0:
			_end_wave()


func _unhandled_input(event: InputEvent) -> void:
	if UIFlow.stack_depth() > 1:
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_I:
				UIFlow.push(SurvivorsBackpackPage, {
					"inventory_data": _inventory_data,
					"equipment_data": _equipment_data,
				})
			KEY_P:
				UIFlow.push(SurvivorsEquipmentPage, {
					"equipment_data": _equipment_data,
					"inventory_data": _inventory_data,
				})
			KEY_ESCAPE:
				UIFlow.push(SurvivorsPausePage)


func _start_wave() -> void:
	_wave += 1
	_between_waves = false
	_kill_tracker.clear()

	var hud := UIFlow.get_page(SurvivorsHUDPage) as SurvivorsHUDPage
	if hud:
		hud.show_wave_start(_wave)

	if _event_bus:
		_event_bus.wave_started.emit(_wave)

	var count := 3 + _wave * 2
	_spawn_enemies(count)


func _end_wave() -> void:
	_between_waves = true
	_wave_timer = _wave_cooldown

	var wave_gold := 10 + _wave * 5
	player_stats.gold += wave_gold

	if _event_bus:
		_event_bus.wave_ended.emit(_wave)

	UIFlow.push(SurvivorsWaveSummaryPage, {
		"wave": _wave,
		"kills": _kill_tracker,
		"on_shop": func():
			UIFlow.replace(SurvivorsShopPage, {
				"player_stats": player_stats,
				"items": _shop_items,
				"inventory_data": _inventory_data,
			}),
		"on_skip": func():
			get_tree().paused = false
			UIFlow.pop()
	})


func _spawn_enemies(count: int) -> void:
	var enemy_script = preload("res://addons/ui_flow_pro/scenes/arpg_enemy.gd")
	var points := _spawn_points.get_children()

	for i in range(count):
		var spawn_point: Node3D = points[i % points.size()]
		var offset := Vector3(randf_range(-2.0, 2.0), 0, randf_range(-2.0, 2.0))

		var enemy: CharacterBody3D = enemy_script.new()
		enemy.position = spawn_point.position + offset

		var stats := SurvivorsEnemyStats.new()
		stats.enemy_name = "Enemy"
		stats.max_health = 20.0 + _wave * 10.0
		stats.health = stats.max_health
		stats.attack = 2 + _wave
		enemy.stats = stats

		enemy.tree_exiting.connect(_on_enemy_died.bind(stats.enemy_name, 25, 5))

		add_child(enemy)


func _on_enemy_died(enemy_name: String, xp: int, gold: int) -> void:
	if not _kill_tracker.has(enemy_name):
		_kill_tracker[enemy_name] = {"count": 0, "xp": 0, "gold": 0}
	_kill_tracker[enemy_name]["count"] += 1
	_kill_tracker[enemy_name]["xp"] += xp
	_kill_tracker[enemy_name]["gold"] += gold

	player_stats.gold += gold

	var gem_script = preload("res://addons/ui_flow_pro/xp_gem.gd")
	var gem: Area3D = gem_script.new()
	gem.xp_amount = xp
	gem.position = _player.global_position + Vector3(randf_range(-3, 3), 0, randf_range(-3, 3))
	add_child(gem)

	if _event_bus:
		_event_bus.enemy_killed.emit(enemy_name, xp, gold)


func _on_xp_gained(amount: float) -> void:
	player_stats.xp += amount

	while player_stats.xp >= _xp_to_next_level:
		player_stats.xp -= _xp_to_next_level
		player_stats.level += 1
		_xp_to_next_level *= 1.5
		player_stats.max_health += 10
		player_stats.health = player_stats.max_health
		player_stats.attack += 2

		if _event_bus:
			_event_bus.level_up.emit(player_stats.level)

		_show_level_up_cards()


func _show_level_up_cards() -> void:
	var all_weapons := _level_up_weapons.duplicate()
	all_weapons.shuffle()
	var cards: Array = all_weapons.slice(0, mini(3, all_weapons.size()))

	UIFlow.push(SurvivorsLevelUpPage, {
		"cards": cards,
		"on_selected": func(weapon: WeaponData):
			player_stats.add_weapon(weapon)
			if _event_bus:
				_event_bus.weapon_acquired.emit(weapon)
	})


func get_event_bus() -> SurvivorsEventBus:
	return _event_bus
