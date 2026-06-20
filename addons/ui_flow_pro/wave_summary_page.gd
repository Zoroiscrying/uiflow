## SurvivorsWaveSummaryPage — post-wave statistics with UIFlowDataGrid.
##
## UIFlow Features Demonstrated:
## - is_modal: Blocks input to pages below
## - UIFlowDataGrid: Sortable table with columns and data
## - UIFlow.anim_stagger_fade: Grid row entry animation
## - Callable data passing (on_shop/on_skip callbacks)
class_name SurvivorsWaveSummaryPage extends UIFlowPage

@onready var _title_label: Label = $VBox/TitleLabel
@onready var _stats_grid: UIFlowDataGrid = $VBox/StatsGrid
@onready var _shop_button: Button = $VBox/Buttons/ShopButton
@onready var _skip_button: Button = $VBox/Buttons/SkipButton

var _wave: int = 0
var _on_shop: Callable
var _on_skip: Callable


func _ready() -> void:
	is_modal = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	_shop_button.pressed.connect(func():
		if _on_shop.is_valid(): _on_shop.call()
	)
	_skip_button.pressed.connect(func():
		if _on_skip.is_valid(): _on_skip.call()
	)


func _on_opened(data: Variant = null) -> void:
	get_tree().paused = true
	if data is Dictionary:
		_wave = data.get("wave", 0)
		_on_shop = data.get("on_shop", Callable())
		_on_skip = data.get("on_skip", Callable())
		var kills: Dictionary = data.get("kills", {})
		_setup_grid(kills)
	_title_label.text = SurvivorsLocalization.locf("wave_complete", [_wave])


func _setup_grid(kills: Dictionary) -> void:
	_stats_grid.add_column(SurvivorsLocalization.loc("enemy"), 150, false)
	_stats_grid.add_column(SurvivorsLocalization.loc("killed"), 80, true)
	_stats_grid.add_column(SurvivorsLocalization.loc("xp"), 80, true)
	_stats_grid.add_column(SurvivorsLocalization.loc("gold"), 80, true)

	var grid_data: Array = []
	for enemy_name in kills:
		var info: Dictionary = kills[enemy_name]
		grid_data.append([
			enemy_name,
			str(info.get("count", 0)),
			str(info.get("xp", 0)),
			str(info.get("gold", 0)),
		])
	_stats_grid.set_data(grid_data)
	UIFlow.anim_stagger_fade(_stats_grid)


func _on_closed() -> void:
	pass  # Pause state managed by the next page (Shop)
