## Brotato-like Arena — top-down wave survival.
extends Node3D

@export var player_stats: ARPGPlayerStats

var _wave: int = 0
var _enemies_alive: int = 0
var _wave_timer: float = 0.0
var _between_waves: bool = true
var _wave_cooldown: float = 3.0

@onready var _player: CharacterBody3D = $Player
@onready var _spawn_points: Node3D = $SpawnPoints


func _ready() -> void:
	if player_stats == null:
		player_stats = ARPGPlayerStats.new()

	await get_tree().process_frame

	# Push HUD
	var hud: ARPGHUDPage = UIFlow.push(ARPGHUDPage, {"player_stats": player_stats}) as ARPGHUDPage

	# Setup player
	_player.stats = player_stats
	_player.set_top_down_camera()

	# Start first wave
	_between_waves = true
	_wave_timer = 2.0


func _process(delta: float) -> void:
	if _between_waves:
		_wave_timer -= delta
		if _wave_timer <= 0:
			_start_wave()
	else:
		# Check if wave is complete
		_enemies_alive = get_tree().get_nodes_in_group("enemies").size()
		if _enemies_alive == 0:
			_between_waves = true
			_wave_timer = _wave_cooldown
			var hud := UIFlow.get_page(ARPGHUDPage) as ARPGHUDPage
			if hud:
				hud.show_wave_complete(_wave)


func _start_wave() -> void:
	_wave += 1
	_between_waves = false

	var hud := UIFlow.get_page(ARPGHUDPage) as ARPGHUDPage
	if hud:
		hud.show_wave_start(_wave)

	# Spawn enemies based on wave number
	var count := 3 + _wave * 2
	_spawn_enemies(count)


func _spawn_enemies(count: int) -> void:
	var enemy_script := preload("res://addons/ui_flow/examples/arpg_hud/scenes/arpg_enemy.gd")
	var points := _spawn_points.get_children()

	for i in range(count):
		var spawn_point: Node3D = points[i % points.size()]
		var offset := Vector3(
			randf_range(-2.0, 2.0), 0, randf_range(-2.0, 2.0)
		)

		var enemy: CharacterBody3D = enemy_script.new()
		enemy.position = spawn_point.position + offset

		var stats := ARPGEnemyStats.new()
		stats.enemy_name = "Enemy"
		stats.max_health = 20.0 + _wave * 10.0
		stats.health = stats.max_health
		stats.attack = 2 + _wave
		enemy.stats = stats

		add_child(enemy)
