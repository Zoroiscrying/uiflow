## A custom transition definition resource.
## Use this to define reusable transitions with specific parameters.
@tool
class_name UIFlowTransition extends Resource

@export var type: UIFlowTransitionType.Type = UIFlowTransitionType.Type.FADE
@export var duration: float = 0.3
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
@export var trans_type: Tween.TransitionType = Tween.TRANS_LINEAR

## Create a UIFlowTransitionBase instance from this resource definition.
func create_instance() -> UIFlowTransitionBase:
	return UIFlow.create_transition(type, duration, ease_type, trans_type)
