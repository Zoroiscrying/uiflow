## GameOverPage — death screen with restart options.
class_name GameOverPage extends UIFlowPage

@onready var _restart_button: Button = $Dimmer/VBox/RestartButton
@onready var _menu_button: Button = $Dimmer/VBox/MenuButton
@onready var _stats_grid: UIFlowDataGrid = $Dimmer/VBox/StatsGrid


func _ready() -> void:
	is_modal = true
	_restart_button.pressed.connect(func(): UIFlow.pop_to_root())
	_menu_button.pressed.connect(func():
		UIFlowUI.Confirm.show_confirm("Quit?", "Return to main menu?", func():
			UIFlow.pop_to_root()
		)
	)


func _on_opened(data: Variant = null) -> void:
	if data is Dictionary:
		var stats: Dictionary = data.get("stats", {})
		_setup_stats(stats)
	UIFlow.set_default_focus(_restart_button)


func _setup_stats(stats: Dictionary) -> void:
	_stats_grid.add_column("Stat", 150, false)
	_stats_grid.add_column("Value", 100, false)
	var grid_data: Array = []
	for key in stats:
		grid_data.append([key, str(stats[key])])
	_stats_grid.set_data(grid_data)
