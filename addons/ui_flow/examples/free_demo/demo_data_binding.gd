## Data Binding Demo — live data → UI updates.
class_name UIFlowDemoDataBinding extends UIFlowPage

signal score_changed(value: int)
signal lives_changed(value: int)

var _score: int = 0:
	set(v): _score = v; score_changed.emit(_score)
var _lives: int = 3:
	set(v): _lives = v; lives_changed.emit(_lives)

@onready var _score_label: Label = $Panel/VBox/ScoreLabel
@onready var _lives_label: Label = $Panel/VBox/LivesLabel
@onready var _score_bar: ProgressBar = $Panel/VBox/ScoreBar
@onready var _add_score_btn: Button = $Panel/VBox/Buttons/AddScore
@onready var _lose_life_btn: Button = $Panel/VBox/Buttons/LoseLife
@onready var _back_button: Button = $Panel/VBox/BackButton

var _bindings: Array = []


func _ready() -> void:
	_add_score_btn.pressed.connect(func(): _score += 10)
	_lose_life_btn.pressed.connect(func(): _lives = maxi(0, _lives - 1))
	_back_button.pressed.connect(func(): UIFlow.pop())


func _on_opened(_data: Variant = null) -> void:
	_score = 0
	_lives = 3

	# Bind signals to UI
	_bindings.append(
		UIFlow.bind_signal_t(_score_label, "text", score_changed,
			func(v): return "Score: %d" % v)
	)
	_bindings.append(
		UIFlow.bind_signal_t(_lives_label, "text", lives_changed,
			func(v): return "Lives: %d" % v)
	)
	_bindings.append(
		UIFlow.bind_signal(_score_bar, "value", score_changed)
	)

	UIFlow.set_default_focus(_add_score_btn)


func _on_closed() -> void:
	for b in _bindings:
		b.unbind()
	_bindings.clear()
