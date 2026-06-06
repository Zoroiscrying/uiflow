## Transition definition resource — defines a transition's type, duration, and easing.
##
## Ships with built-in presets as .tres files in transitions/presets/.
## Users can create custom .tres presets in the Inspector.
##
## Built-in presets:
## - none.tres: Instant (no animation)
## - fade.tres: Fade in/out
## - slide_left.tres: Slide from right
## - slide_right.tres: Slide from left
## - slide_up.tres: Slide from bottom
## - slide_down.tres: Slide from top
## - scale.tres: Scale from zero
@tool
class_name UIFlowTransition extends Resource

@export var type: UIFlowTransitionType.Type = UIFlowTransitionType.Type.FADE
@export var duration: float = 0.3
@export_range(0.0, 2.0, 0.05) var delay: float = 0.0
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
@export var trans_type: Tween.TransitionType = Tween.TRANS_LINEAR

## Create a UIFlowTransitionBase instance from this resource definition.
func create_instance() -> UIFlowTransitionBase:
	match type:
		UIFlowTransitionType.Type.NONE:
			return UIFlowTransitionNone.new()
		UIFlowTransitionType.Type.FADE:
			return UIFlowTransitionFade.new(duration, ease_type, trans_type)
		UIFlowTransitionType.Type.SLIDE_LEFT:
			return UIFlowTransitionSlideLeft.new(duration, ease_type, trans_type)
		UIFlowTransitionType.Type.SLIDE_RIGHT:
			return UIFlowTransitionSlideRight.new(duration, ease_type, trans_type)
		UIFlowTransitionType.Type.SLIDE_UP:
			return UIFlowTransitionSlideUp.new(duration, ease_type, trans_type)
		UIFlowTransitionType.Type.SLIDE_DOWN:
			return UIFlowTransitionSlideDown.new(duration, ease_type, trans_type)
		UIFlowTransitionType.Type.SCALE:
			return UIFlowTransitionScale.new(duration, ease_type, trans_type)
		_:
			return UIFlowTransitionNone.new()
