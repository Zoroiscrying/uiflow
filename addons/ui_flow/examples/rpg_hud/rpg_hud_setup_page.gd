## RPG HUD Setup Page — initializes EventBus and game simulation,
## then pushes the actual HUD page.
class_name RPGHudSetupPage extends UIFlowPage

var _game_events: GameEvents
var _stats: PlayerStats
var _is_pausing: bool = false


func _on_enter(_data: Dictionary = {}) -> void:
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
		if _is_pausing:
			return
		if UIFlow.current_page() == PausePage:
			return
		_is_pausing = true
		UIFlow.push(PausePage, {}, UIFlowTransitionType.Type.FADE)
		# Reset flag after a short delay
		get_tree().create_timer(0.5).timeout.connect(func(): _is_pausing = false)
	)


func _on_exit() -> void:
	UIFlow.reset_back_callback()
	if _game_events:
		_game_events.queue_free()


func _on_resume() -> void:
	_is_pausing = false
	_set_pause_back()
