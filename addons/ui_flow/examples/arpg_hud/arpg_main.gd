## ARPG Example — main entry point.
## Sets up the 3D world, player, enemies, and HUD.
extends Node3D

@export var player_stats: ARPGPlayerStats


func _ready() -> void:
	if player_stats == null:
		player_stats = ARPGPlayerStats.new()

	# Wait for scene tree to stabilize
	await get_tree().process_frame

	# Push HUD
	var hud: ARPGHUDPage = UIFlow.push(ARPGHUDPage) as ARPGHUDPage
	hud.player_stats = player_stats

	# Give player stats to the player character
	var player := get_node_or_null("Player") as CharacterBody3D
	if player:
		player.stats = player_stats

	# Give stats to enemies
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("set_stats"):
			enemy.set_stats(ARPGEnemyStats.new())
