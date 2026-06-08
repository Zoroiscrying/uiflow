## Bridge between UIFlowTransitionEffect and UIFlowTransitionBase.
class_name UIFlowTransitionEffectBridge extends UIFlowTransitionBase

var _enter_effect  # UIFlowTransitionEffect
var _exit_effect   # UIFlowTransitionEffect


func _init(enter_eff = null, exit_eff = null) -> void:
	_enter_effect = enter_eff
	_exit_effect = exit_eff


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	if _enter_effect and _enter_effect.has_method("play_enter"):
		_enter_effect.play_enter(node, callback)
	else:
		if callback.is_valid():
			callback.call()


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	if _exit_effect and _exit_effect.has_method("play_exit"):
		_exit_effect.play_exit(node, callback)
	else:
		if callback.is_valid():
			callback.call()
