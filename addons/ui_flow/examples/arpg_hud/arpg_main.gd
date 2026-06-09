## ARPG Example — main entry point.
## 3D arena with player, enemies, and HUD.
extends Node3D

@export var player_stats: ARPGPlayerStats


func _ready() -> void:
	if player_stats == null:
		player_stats = ARPGPlayerStats.new()

	await get_tree().process_frame

	# Push HUD
	var hud: ARPGHUDPage = UIFlow.push(ARPGHUDPage) as ARPGHUDPage
	hud.player_stats = player_stats

	# Give stats to player
	var player := get_node_or_null("Player")
	if player:
		player.stats = player_stats

	# Create enemies
	_spawn_enemies()


func _spawn_enemies() -> void:
	var enemy_scene := preload("res://addons/ui_flow/examples/arpg_hud/scenes/arpg_enemy.gd")
	var positions := [
		Vector3(5, 0, -3),
		Vector3(-4, 0, 5),
		Vector3(6, 0, 6),
		Vector3(-6, 0, -5),
		Vector3(0, 0, -7),
	]

	for pos in positions:
		var enemy: CharacterBody3D = enemy_scene.new()
		enemy.position = pos
		var stats := ARPGEnemyStats.new()
		stats.enemy_name = "Slime"
		stats.max_health = 30.0 + randf() * 40.0
		stats.health = stats.max_health
		stats.attack = 3 + randi() % 5
		enemy.stats = stats
		add_child(enemy)
