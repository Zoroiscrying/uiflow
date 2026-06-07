## RPG HUD Setup Page — initializes EventBus and game simulation,
## then pushes the actual HUD page.
class_name RPGHudSetupPage extends UIFlowPage

var _game_events: GameEvents
var _stats: PlayerStats
var _is_pausing: bool = false


func _on_opened(_data: Dictionary = {}) -> void:
	_is_pausing = false

	# Create event bus
	_game_events = GameEvents.new()
	_game_events.name = "GameEvents"
	add_child(_game_events)

	# Create stats
	_stats = PlayerStats.new()

	# Push HUD
	var hud: HUDPage = UIFlow.push(HUDPage, {}, UIFlowTransitionType.Type.NONE) as HUDPage
	hud.stats = _stats
	hud.game_events = _game_events

	# Connect action buttons
	$Actions/Margin/Buttons/DamageButton.pressed.connect(func():
		_stats.health -= 20.0
		if _stats.health <= 0:
			_game_events.player_died.emit()
	)
	$Actions/Margin/Buttons/HealButton.pressed.connect(func():
		_stats.health += 30.0
	)
	$Actions/Margin/Buttons/ManaButton.pressed.connect(func():
		_stats.mana -= 10.0
		if _stats.mana < 0:
			_stats.mana = 0.0
	)
	$Actions/Margin/Buttons/GoldButton.pressed.connect(func():
		_stats.gold += 25
		_game_events.item_acquired.emit(&"gold_coin", 25)
	)
	$Actions/Margin/Buttons/LevelButton.pressed.connect(func():
		_stats.level += 1
		_game_events.level_up.emit(_stats.level)
	)

	_set_pause_back()


func _set_pause_back() -> void:
	UIFlow.set_back_callback(func():
		# Guard: don't push if PausePage is already in stack OR being pushed
		if _is_pausing or UIFlow.has_page(PausePage):
			return
		_is_pausing = true
		# Use NONE transition — PausePage handles its own animation internally
		UIFlow.push(PausePage, {}, UIFlowTransitionType.Type.NONE)
		# Reset guard after a delay (prevent rapid re-trigger)
		get_tree().create_timer(0.3).timeout.connect(func(): _is_pausing = false)
	)


func _on_closed() -> void:
	UIFlow.reset_back_callback()
	if _game_events:
		_game_events.queue_free()


func _on_shown() -> void:
	# Disable back completely during cooldown to prevent autoload + callback conflict
	UIFlow.set_back_enabled(false)
	_is_pausing = true
	get_tree().create_timer(0.5).timeout.connect(func():
		_is_pausing = false
		_set_pause_back()
		UIFlow.set_back_enabled(true)
	)
