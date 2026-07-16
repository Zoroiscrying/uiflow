## Target page used by the Timeline & Async Loading demo.
## Receives an optional [code]enter_effect[/code] and title via push data.
class_name TimelineAsyncTargetPage extends UIFlowPage

@onready var _back_button: Button = $Center/BackButton


func _ready() -> void:
	_back_button.pressed.connect(func(): UIFlow.pop())


func _on_created(data: Variant = null) -> void:
	var dict := _as_dict(data)
	$Center/NameLabel.text = dict.get("title", "Target")
	_setup_punch_scale_timeline()


func _setup_punch_scale_timeline() -> void:
	# Two-step scale punch: 0 -> 0.5 -> 1.0 using a back (overshoot) curve.
	var step_1 := UIFlowScaleEffect.new()
	step_1.hidden_scale = Vector2.ZERO
	step_1.visible_scale = Vector2(0.5, 0.5)
	step_1.duration = 0.18
	step_1.trans_type = Tween.TRANS_BACK
	step_1.ease_type = Tween.EASE_OUT

	var step_2 := UIFlowScaleEffect.new()
	step_2.hidden_scale = Vector2(0.5, 0.5)
	step_2.visible_scale = Vector2.ONE
	step_2.duration = 0.25
	step_2.trans_type = Tween.TRANS_BACK
	step_2.ease_type = Tween.EASE_OUT

	var timeline := UIFlowTimelineEffect.new()
	timeline.effects = [step_1, step_2]
	timeline.step_delays = [0.0, 0.0]
	timeline.step_wait_for_completion = [true, true]
	enter_effect = timeline


func _on_opened(_data: Variant = null) -> void:
	UIFlow.set_default_focus(_back_button)
