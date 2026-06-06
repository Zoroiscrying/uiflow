## General-purpose UI animation utility.
## Animate any property on any node using TweenProp enums instead of string paths.
class_name UIFlowAnimator

## Animate a property on a node from [param from] to [param to] over [param duration] seconds.
## Returns the Tween for chaining or awaiting.
##
## Example:
## [codeblock]
## UIFlow.animate($Panel, UIFlowTweenProp.Prop.MODULATE_A, 0.0, 1.0, 0.3)
## await UIFlow.animate($Panel, UIFlowTweenProp.Prop.POSITION_X, -400, 0, 0.4).finished
## [/codeblock]
static func animate(
	node: Node,
	prop: UIFlowTweenProp.Prop,
	from: Variant,
	to: Variant,
	duration: float = 0.3,
	ease_type: Tween.EaseType = Tween.EASE_IN_OUT,
	trans_type: Tween.TransitionType = Tween.TRANS_LINEAR
) -> Tween:
	if not is_instance_valid(node):
		return null

	var prop_path: String = UIFlowTweenProp.to_path(prop)
	if prop_path.is_empty():
		push_warning("UIFlowAnimator: Invalid tween property.")
		return null

	var tween: Tween = node.create_tween()
	node.set(prop_path, from)
	tween.tween_property(node, prop_path, to, duration).set_ease(ease_type).set_trans(trans_type)
	return tween


## Animate using a raw Godot property path string (for non-standard properties).
##
## Example:
## [codeblock]
## UIFlow.animate_raw($Node, "custom_property/my_value", 0, 100, 0.5)
## [/codeblock]
static func animate_raw(
	node: Node,
	prop_path: String,
	from: Variant,
	to: Variant,
	duration: float = 0.3,
	ease_type: Tween.EaseType = Tween.EASE_IN_OUT,
	trans_type: Tween.TransitionType = Tween.TRANS_LINEAR
) -> Tween:
	if not is_instance_valid(node):
		return null

	var tween: Tween = node.create_tween()
	node.set(prop_path, from)
	tween.tween_property(node, prop_path, to, duration).set_ease(ease_type).set_trans(trans_type)
	return tween


## Create a sequencer for multi-element animations (Pro feature placeholder).
## For now, returns a simple sequencer that plays animations in sequence.
static func sequencer() -> UIFlowSequencer:
	return UIFlowSequencer.new()
