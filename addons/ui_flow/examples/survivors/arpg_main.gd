## Brotato-like Arena — top-down wave survival with UIFlow UI demo.
extends Node3D

@export var player_stats: SurvivorsPlayerStats

var _wave: int = 0
var _enemies_alive: int = 0
var _wave_timer: float = 0.0
var _between_waves: bool = true
var _wave_cooldown: float = 3.0

var _inventory_data: InventoryData
var _equipment_data: EquipmentData
var _shop_items: Array[ItemData] = []

@onready var _player: CharacterBody3D = $Player
@onready var _spawn_points: Node3D = $SpawnPoints


func _ready() -> void:
	if player_stats == null:
		player_stats = SurvivorsPlayerStats.new()

	_setup_inventory()
	_setup_equipment()
	_setup_shop_items()

	await get_tree().process_frame

	# Push HUD
	var _hud: SurvivorsHUDPage = UIFlow.push(SurvivorsHUDPage, {"player_stats": player_stats}) as SurvivorsHUDPage

	# Setup player
	_player.stats = player_stats
	_player.set_top_down_camera()

	# Start first wave
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


func _process(delta: float) -> void:
	if _between_waves:
		_wave_timer -= delta
		if _wave_timer <= 0:
			_start_wave()
	else:
		_enemies_alive = get_tree().get_nodes_in_group("enemies").size()
		if _enemies_alive == 0:
			_between_waves = true
			_wave_timer = _wave_cooldown
			var hud := UIFlow.get_page(SurvivorsHUDPage) as SurvivorsHUDPage
			if hud:
				hud.show_wave_complete(_wave)
			# Wave reward
			player_stats.gold += 10 + _wave * 5


func _unhandled_input(event: InputEvent) -> void:
	# Don't handle input if a modal page is open
	if UIFlow.stack_depth() > 1:
		return

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_I:
				_open_inventory()
			KEY_O:
				_open_shop()
			KEY_P:
				_open_equipment()


func _open_inventory() -> void:
	UIFlow.push(SurvivorsBackpackPage, {
		"inventory_data": _inventory_data,
		"equipment_data": _equipment_data,
	})


func _open_shop() -> void:
	UIFlow.push(SurvivorsShopPage, {
		"player_stats": player_stats,
		"items": _shop_items,
		"inventory_data": _inventory_data,
	})


func _open_equipment() -> void:
	UIFlow.push(SurvivorsEquipmentPage, {
		"equipment_data": _equipment_data,
		"inventory_data": _inventory_data,
	})


func _start_wave() -> void:
	_wave += 1
	_between_waves = false

	var hud := UIFlow.get_page(SurvivorsHUDPage) as SurvivorsHUDPage
	if hud:
		hud.show_wave_start(_wave)

	var count := 3 + _wave * 2
	_spawn_enemies(count)


func _spawn_enemies(count: int) -> void:
	var enemy_script := preload("res://addons/ui_flow/examples/survivors/scenes/arpg_enemy.gd")
	var points := _spawn_points.get_children()

	for i in range(count):
		var spawn_point: Node3D = points[i % points.size()]
		var offset := Vector3(
			randf_range(-2.0, 2.0), 0, randf_range(-2.0, 2.0)
		)

		var enemy: CharacterBody3D = enemy_script.new()
		enemy.position = spawn_point.position + offset

		var stats := SurvivorsEnemyStats.new()
		stats.enemy_name = "Enemy"
		stats.max_health = 20.0 + _wave * 10.0
		stats.health = stats.max_health
		stats.attack = 2 + _wave
		enemy.stats = stats

		add_child(enemy)
