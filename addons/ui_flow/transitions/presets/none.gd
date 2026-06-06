## No transition — pages appear/disappear instantly.
class_name UIFlowTransitionNone extends UIFlowTransitionBase

func play_enter(node: Control, callback: Callable = Callable()) -> void:
	node.visible = true
	node.modulate.a = 1.0
	if callback.is_valid():
		callback.call()

func play_exit(node: Control, callback: Callable = Callable()) -> void:
	if callback.is_valid():
		callback.call()
