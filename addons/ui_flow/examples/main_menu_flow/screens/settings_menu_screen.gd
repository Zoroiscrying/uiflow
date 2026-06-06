## Settings menu placeholder — shows navigation depth.
class_name SettingsMenuScreen extends UIFlowPage

func _ready() -> void:
	$Center/BackButton.pressed.connect(func(): UIFlow.pop())


func _on_enter(_data: Dictionary = {}) -> void:
	$Center/DepthLabel.text = "Stack depth: %d" % UIFlow.stack_depth()
	UIFlow.set_default_focus($Center/BackButton)
