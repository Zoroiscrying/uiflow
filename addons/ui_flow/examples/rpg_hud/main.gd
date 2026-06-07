## RPG HUD example — data binding, EventBus, pause menu, toast notifications.
##
## Press Escape to open pause menu.
## Use buttons to simulate game events (damage, heal, earn gold, level up).
extends Control

@export var stats: PlayerStats

var _game_events: GameEvents


func _ready() -> void:
	if stats == null:
		stats = PlayerStats.new()

	# Create event bus
	_game_events = GameEvents.new()
	_game_events.name = "GameEvents"
	add_child(_game_events)

	# Push HUD
	var hud: HUDPage = UIFlow.push(HUDPage) as HUDPage
	hud.stats = stats

	# Set up back button to open pause menu instead of popping HUD
	UIFlow.set_back_callback(func():
		if UIFlow.current_page() != PausePage:
			UIFlow.push(PausePage, {})
	)

	# Connect action buttons
	$Actions/DamageButton.pressed.connect(func():
		stats.health -= 20.0
		if stats.health <= 0:
			_game_events.player_died.emit()
	)
	$Actions/HealButton.pressed.connect(func():
		stats.health += 30.0
	)
	$Actions/ManaButton.pressed.connect(func():
		stats.mana -= 10.0
		if stats.mana < 0:
			stats.mana = 0.0
	)
	$Actions/GoldButton.pressed.connect(func():
		stats.gold += 25
		_game_events.item_acquired.emit(&"gold_coin", 25)
	)
	$Actions/LevelButton.pressed.connect(func():
		stats.level += 1
		_game_events.level_up.emit(stats.level)
	)
