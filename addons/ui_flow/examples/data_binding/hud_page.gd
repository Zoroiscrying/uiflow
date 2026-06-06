## Example HUD page — demonstrates data binding with UIFlowDataStore.
extends UIFlowPage

@export var player_data: PlayerData

var _bindings: Array[UIFlowBindUtils.UIFlowBinding] = []


func _on_enter(_data: Dictionary = {}) -> void:
	if player_data == null:
		push_warning("HUDPage: player_data not set!")
		return

	# Bind health → progress bar
	_bindings.append(
		UIFlow.bind_signal($VBox/HealthBar, "value", player_data.health_changed)
	)

	# Bind health → label with format
	_bindings.append(
		UIFlow.bind_signal_t($VBox/HealthLabel, "text", player_data.health_changed,
			func(v): return "HP: %d / %d" % [int(v), int(player_data.max_health)])
	)

	# Bind gold → label
	_bindings.append(
		UIFlow.bind_signal_t($VBox/GoldLabel, "text", player_data.gold_changed,
			func(v): return "Gold: %d" % v)
	)

	# Bind low health warning visibility
	_bindings.append(
		UIFlow.bind_visible($VBox/LowHealthWarning, player_data.health_changed,
			func(v): return v < 30.0)
	)

	# Initialize display
	$VBox/HealthBar.value = player_data.health
	$VBox/HealthLabel.text = "HP: %d / %d" % [int(player_data.health), int(player_data.max_health)]
	$VBox/GoldLabel.text = "Gold: %d" % player_data.gold
	$VBox/LowHealthWarning.visible = player_data.health < 30.0


func _on_exit() -> void:
	# Clean up bindings
	for binding in _bindings:
		binding.unbind()
	_bindings.clear()
