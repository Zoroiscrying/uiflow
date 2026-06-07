## RPG HUD — demonstrates data binding + EventBus + pause menu.
class_name HUDPage extends UIFlowPage

@export var stats: PlayerStats
var game_events: GameEvents

var _bindings: Array[UIFlowBindUtils.UIFlowBinding] = []


func _on_opened(_data: Dictionary = {}) -> void:
	if stats == null:
		return

	# Health bar binding
	_bindings.append(
		UIFlow.bind_signal($HUD/HealthBar, "value", stats.health_changed)
	)
	_bindings.append(
		UIFlow.bind_signal_t($HUD/HealthLabel, "text", stats.health_changed,
			func(v): return "HP: %d / %d" % [int(v), int(stats.max_health)])
	)

	# Mana bar binding
	_bindings.append(
		UIFlow.bind_signal($HUD/ManaBar, "value", stats.mana_changed)
	)
	_bindings.append(
		UIFlow.bind_signal_t($HUD/ManaLabel, "text", stats.mana_changed,
			func(v): return "MP: %d / %d" % [int(v), int(stats.max_mana)])
	)

	# Gold binding
	_bindings.append(
		UIFlow.bind_signal_t($HUD/GoldLabel, "text", stats.gold_changed,
			func(v): return "Gold: %d" % v)
	)

	# Level binding
	_bindings.append(
		UIFlow.bind_signal_t($HUD/LevelLabel, "text", stats.level_changed,
			func(v): return "Lv. %d" % v)
	)

	# Listen to game events (if instance provided)
	if game_events:
		game_events.player_died.connect(_on_player_died)
		game_events.level_up.connect(_on_level_up)
		game_events.item_acquired.connect(_on_item_acquired)

	# Initialize display
	$HUD/HealthBar.max_value = stats.max_health
	$HUD/HealthBar.value = stats.health
	$HUD/ManaBar.max_value = stats.max_mana
	$HUD/ManaBar.value = stats.mana


func _on_closed() -> void:
	for b in _bindings:
		b.unbind()
	_bindings.clear()
	if game_events:
		if game_events.player_died.is_connected(_on_player_died):
			game_events.player_died.disconnect(_on_player_died)
		if game_events.level_up.is_connected(_on_level_up):
			game_events.level_up.disconnect(_on_level_up)
		if game_events.item_acquired.is_connected(_on_item_acquired):
			game_events.item_acquired.disconnect(_on_item_acquired)


func _on_player_died() -> void:
	UIFlowUI.Toast.show_toast("You died!", UIFlowToast.Type.ERROR)


func _on_level_up(new_level: int) -> void:
	UIFlowUI.Toast.show_toast("Level Up! Now level %d" % new_level, UIFlowToast.Type.SUCCESS)


func _on_item_acquired(item_id: StringName, count: int) -> void:
	UIFlowUI.Toast.show_toast("Got %s x%d" % [item_id, count], UIFlowToast.Type.INFO)
