## Settings menu placeholder — shows navigation depth.
class_name SettingsMenuScreen extends UIFlowPage

var _connected: bool = false


func _on_enter(_data: Dictionary = {}) -> void:
	$Center/DepthLabel.text = "Stack depth: %d" % UIFlow.stack_depth()
	UIFlow.set_default_focus($Center/BackButton)

	if not _connected:
		$Center/BackButton.pressed.connect(func(): UIFlow.pop())
		_connected = true


func _on_resume() -> void:
	$Center/DepthLabel.text = "Stack depth: %d" % UIFlow.stack_depth()
	UIFlow.set_default_focus($Center/BackButton)
