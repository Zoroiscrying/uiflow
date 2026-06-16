## WeaponManager — auto-attacks with all equipped weapons.
extends Node

var player_stats: SurvivorsPlayerStats
var _cooldowns: Dictionary = {}  # weapon_index -> float

func setup(stats: SurvivorsPlayerStats) -> void:
	player_stats = stats
	_cooldowns.clear()
	for i in range(stats.get_weapons().size()):
		_cooldowns[i] = 0.0
	stats.weapons_changed.connect(_on_weapons_changed)


func _on_weapons_changed() -> void:
	_cooldowns.clear()
	for i in range(player_stats.get_weapons().size()):
		if not _cooldowns.has(i):
			_cooldowns[i] = 0.0


func update(delta: float, player_pos: Vector3) -> WeaponData:
	if player_stats == null:
		return null

	var weapons := player_stats.get_weapons()

	for i in range(weapons.size()):
		var weapon: WeaponData = weapons[i]
		if weapon == null:
			continue

		_cooldowns[i] = maxf(_cooldowns.get(i, 0.0) - delta, 0.0)
		if _cooldowns[i] <= 0.0:
			var target := _find_nearest_enemy(player_pos, weapon.range)
			if target:
				_cooldowns[i] = weapon.cooldown
				return weapon

	return null


func get_target_for_weapon(weapon: WeaponData, player_pos: Vector3) -> Node3D:
	return _find_nearest_enemy(player_pos, weapon.range)


func _find_nearest_enemy(pos: Vector3, max_range: float) -> Node3D:
	var enemies: Array = Engine.get_main_loop().current_scene.get_tree().get_nodes_in_group("enemies")
	var nearest: Node3D = null
	var nearest_dist := max_range

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var enemy_stats: SurvivorsEnemyStats = enemy.get("stats")
		if enemy_stats == null or not enemy_stats.is_alive():
			continue
		var dist := pos.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy

	return nearest
