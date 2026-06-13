## Data Binding Demo — live data → UI updates with multiple binding types.
class_name UIFlowDemoDataBinding extends UIFlowPage

signal score_changed(value: int)
signal lives_changed(value: int)
signal combo_changed(value: int)

var _score: int = 0:
	set(v): _score = v; score_changed.emit(_score)
var _lives: int = 3:
	set(v): _lives = v; lives_changed.emit(_lives)
var _combo: int = 0:
	set(v): _combo = v; combo_changed.emit(_combo)

@onready var _score_label: Label = $Panel/VBox/ScoreLabel
@onready var _lives_label: Label = $Panel/VBox/LivesLabel
@onready var _score_bar: ProgressBar = $Panel/VBox/ScoreBar
@onready var _combo_label: Label = $Panel/VBox/ComboLabel
@onready var _bonus_label: Label = $Panel/VBox/BonusLabel
@onready var _danger_panel: PanelContainer = $Panel/VBox/DangerPanel
@onready var _add_score_btn: Button = $Panel/VBox/Buttons/AddScore
@onready var _lose_life_btn: Button = $Panel/VBox/Buttons/LoseLife
@onready var _add_combo_btn: Button = $Panel/VBox/Buttons/AddCombo
@onready var _back_button: Button = $Panel/VBox/BackButton

var _bindings: Array = []


func _ready() -> void:
	_add_score_btn.pressed.connect(func(): _score += 10)
	_lose_life_btn.pressed.connect(func(): _lives = maxi(0, _lives - 1))
	_add_combo_btn.pressed.connect(func(): _combo += 1)
	_back_button.pressed.connect(func(): UIFlow.pop())


func _on_opened(_data: Variant = null) -> void:
	_score = 0
	_lives = 3
	_combo = 0

	# bind_signal_t: signal value → transform → label text
	_bindings.append(
		UIFlow.bind_signal_t(_score_label, "text", score_changed,
			func(v): return "Score: %d" % v)
	)
	_bindings.append(
		UIFlow.bind_signal_t(_lives_label, "text", lives_changed,
			func(v): return "Lives: %d" % v)
	)

	# bind_signal: signal value → ProgressBar.value
	_bindings.append(
		UIFlow.bind_signal(_score_bar, "value", score_changed)
	)

	# bind_format: signal value → format string → label text
	_bindings.append(
		UIFlow.bind_format(_combo_label, "text", combo_changed, "Combo: %sx")
	)

	# bind_visible: signal value → predicate → visibility
	# Show bonus label only when combo > 3
	_bindings.append(
		UIFlow.bind_visible(_bonus_label, combo_changed,
			func(v): return v > 3)
	)

	# bind_visible: show danger panel when lives <= 1
	_bindings.append(
		UIFlow.bind_visible(_danger_panel, lives_changed,
			func(v): return v <= 1)
	)

	UIFlow.set_default_focus(_add_score_btn)


func _on_closed() -> void:
	for b in _bindings:
		b.unbind()
	_bindings.clear()
