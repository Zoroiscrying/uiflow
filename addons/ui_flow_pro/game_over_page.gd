## GameOverPage — death screen with restart options.
##
## UIFlow Features Demonstrated:
## - is_modal: Blocks input to pages below
## - UIFlowDataGrid: Final statistics table
## - UIFlowUI.Confirm: Confirmation dialog
## - UIFlow.pop_to_root(): Stack reset to root page
class_name GameOverPage extends UIFlowPage

@onready var _restart_button: Button = $Dimmer/VBox/RestartButton
@onready var _menu_button: Button = $Dimmer/VBox/MenuButton
@onready var _stats_grid: UIFlowDataGrid = $Dimmer/VBox/StatsGrid
@onready var _title_label: Label = $Dimmer/VBox/TitleLabel


func _ready() -> void:
	is_modal = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	_restart_button.pressed.connect(func(): UIFlow.pop_to_root())
	_menu_button.pressed.connect(func():
		UIFlowUI.Confirm.show_confirm(
			SurvivorsLocalization.loc("quit_confirm_title"),
			SurvivorsLocalization.loc("quit_confirm_msg"),
			func(): UIFlow.pop_to_root()
		)
	)


func _on_opened(data: Variant = null) -> void:
	if data is Dictionary:
		var stats: Dictionary = data.get("stats", {})
		_setup_stats(stats)
	_update_language()
	SurvivorsLocalization.language_changed.connect(_update_language)
	UIFlow.set_default_focus(_restart_button)


func _on_closed() -> void:
	if SurvivorsLocalization.language_changed.is_connected(_update_language):
		SurvivorsLocalization.language_changed.disconnect(_update_language)


func _setup_stats(stats: Dictionary) -> void:
	_stats_grid.add_column(SurvivorsLocalization.loc("stat"), 150, false)
	_stats_grid.add_column(SurvivorsLocalization.loc("value"), 100, false)
	var grid_data: Array = []
	for key in stats:
		grid_data.append([key, str(stats[key])])
	_stats_grid.set_data(grid_data)


func _update_language() -> void:
	_title_label.text = SurvivorsLocalization.loc("game_over")
	_restart_button.text = SurvivorsLocalization.loc("restart")
	_menu_button.text = SurvivorsLocalization.loc("main_menu")
