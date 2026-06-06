## Base class for UIFlow transitions.
## Extend this class to create custom transition effects.
##
## A transition defines how pages enter and exit the screen.
## Register custom transitions via [code]UIFlow.register_transition()[/code].
class_name UIFlowTransitionBase extends RefCounted

## Play the enter animation for a page becoming visible.
## Call [param callback] when the animation completes.
func play_enter(_node: Control, _callback: Callable = Callable()) -> void:
	if _callback.is_valid():
		_callback.call()

## Play the exit animation for a page being hidden/removed.
## Call [param callback] when the animation completes.
func play_exit(_node: Control, _callback: Callable = Callable()) -> void:
	if _callback.is_valid():
		_callback.call()
