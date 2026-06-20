## Transition demo page — configured via push data.
##
## Usage:
##   UIFlow.push(TransitionDemoPage, {
##       "transition_name": "Fade",
##       "enter_preset": UIFlowTransitionType.Type.FADE,
##       "enter_duration": 0.3,
##   })
class_name TransitionDemoPage extends UIFlowPage

@onready var _back_button: Button = $Center/BackButton


func _ready() -> void:
	_back_button.pressed.connect(func(): UIFlow.pop())


func _on_created(data: Variant = null) -> void:
	# Configure enter transition from data
	var preset = data.get("enter_preset", UIFlowTransitionType.Type.NONE)
	var duration: float = data.get("enter_duration", 0.3)
	var ease = data.get("enter_ease", Tween.EASE_IN_OUT)
	var trans = data.get("enter_trans", Tween.TRANS_LINEAR)

	if preset != UIFlowTransitionType.Type.NONE:
		var effect := _create_effect(preset, duration, ease, trans)
		if effect:
			enter_effect = effect

	var trans_name: String = data.get("transition_name", "Unknown")
	$Center/NameLabel.text = "Transition: %s" % trans_name


func _create_effect(preset: int, duration: float, ease: int, trans: int) -> UIFlowTransitionEffect:
	match preset:
		UIFlowTransitionType.Type.FADE:
			var e := UIFlowFadeEffect.new()
			e.duration = duration
			e.ease_type = ease
			e.trans_type = trans
			return e
		UIFlowTransitionType.Type.SCALE:
			var e := UIFlowScaleEffect.new()
			e.duration = duration
			e.ease_type = ease
			e.trans_type = trans
			return e
		UIFlowTransitionType.Type.SLIDE_LEFT:
			var e := UIFlowSlideEffect.new()
			e.direction = UIFlowSlideEffect.Direction.LEFT
			e.duration = duration
			e.ease_type = ease
			e.trans_type = trans
			return e
		UIFlowTransitionType.Type.SLIDE_RIGHT:
			var e := UIFlowSlideEffect.new()
			e.direction = UIFlowSlideEffect.Direction.RIGHT
			e.duration = duration
			e.ease_type = ease
			e.trans_type = trans
			return e
		UIFlowTransitionType.Type.SLIDE_UP:
			var e := UIFlowSlideEffect.new()
			e.direction = UIFlowSlideEffect.Direction.UP
			e.duration = duration
			e.ease_type = ease
			e.trans_type = trans
			return e
		UIFlowTransitionType.Type.SLIDE_DOWN:
			var e := UIFlowSlideEffect.new()
			e.direction = UIFlowSlideEffect.Direction.DOWN
			e.duration = duration
			e.ease_type = ease
			e.trans_type = trans
			return e
	return UIFlowFadeEffect.new()


func _on_opened(_data: Variant = null) -> void:
	UIFlow.set_default_focus(_back_button)
