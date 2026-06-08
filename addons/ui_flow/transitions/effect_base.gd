## UIFlowTransitionEffect — base Resource for transition effects.
##
## Each effect is a self-contained Resource that defines how a node
## enters or exits the screen. Extend this class to create custom effects.
##
## Built-in effects:
## - UIFlowFadeEffect: opacity animation
## - UIFlowSlideEffect: position animation
## - UIFlowScaleEffect: scale animation
## - UIFlowCompositeEffect: combines multiple effects
##
## Custom effect example:
## [codeblock]
## class_name MyBounceEffect extends UIFlowTransitionEffect
##
## func play_enter(node: Control, callback: Callable) -> void:
##     var tween = node.get_tree().create_tween()
##     # ... custom animation ...
##     tween.finished.connect(callback)
##
## func play_exit(node: Control, callback: Callable) -> void:
##     # ... reverse animation ...
## [/codeblock]
@tool
class_name UIFlowTransitionEffect extends Resource

## Animation duration in seconds.
@export_range(0.0, 2.0, 0.05) var duration: float = 0.3

## Easing function.
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT

## Transition curve.
@export var trans_type: Tween.TransitionType = Tween.TRANS_LINEAR

## Delay before animation starts.
@export_range(0.0, 2.0, 0.05) var delay: float = 0.0


## Play the enter animation. Override in subclasses.
func play_enter(node: Control, callback: Callable = Callable()) -> void:
	_on_finished(callback)


## Play the exit animation. Override in subclasses.
func play_exit(node: Control, callback: Callable = Callable()) -> void:
	_on_finished(callback)


## Call this when the animation finishes.
func _on_finished(callback: Callable) -> void:
	if not callback.is_valid():
		return
	if delay > 0.0:
		var tree: SceneTree = Engine.get_main_loop() as SceneTree
		if tree:
			tree.create_timer(delay).timeout.connect(func():
				if callback.is_valid():
					callback.call()
			, CONNECT_ONE_SHOT)
	else:
		callback.call()


## Helper: create a tween on the node's tree.
func _create_tween(node: Node) -> Tween:
	if not is_instance_valid(node):
		return null
	var tree: SceneTree = node.get_tree() if node.is_inside_tree() else null
	if tree == null:
		tree = Engine.get_main_loop() as SceneTree
	return tree.create_tween() if tree else null
